{ pkgs, lib, config, ... }:
let
  # Tesseract has no "universal" model: recognition data is per-language, and
  # shipping all of them costs ~1.1GB of closure. We install the Latin-script
  # languages we might realistically hit (~220MB) and default to eng+fra;
  # any subset can be picked at runtime with OCR_LANG, e.g.
  #   OCR_LANG=deu ocr-region
  #   OCR_LANG=eng+fra+spa ocr-region
  tesseract = pkgs.tesseract.override {
    enableLanguages = [ "eng" "fra" "deu" "spa" "ita" "por" "nld" "osd" ];
  };

  # Select a screen region, OCR it, copy the result to the clipboard and show
  # it in a window so the text can be selected by hand.
  ocr-region = pkgs.writeShellApplication {
    name = "ocr-region";
    runtimeInputs = with pkgs; [
      slurp
      grim
      imagemagick
      tesseract
      wl-clipboard
      zenity
      libnotify
    ];
    text = ''
      lang="''${OCR_LANG:-eng+fra}"

      # slurp exits non-zero when the selection is cancelled (Escape)
      geometry=$(slurp -d) || exit 0

      img=$(mktemp --tmpdir ocr-region.XXXXXX.png)
      txt=$(mktemp --tmpdir ocr-region.XXXXXX.txt)
      trap 'rm -f "$img" "$txt"' EXIT

      if ! grim -g "$geometry" -t png "$img"; then
        notify-send -a "OCR" "OCR" "Could not capture the selected region"
        exit 1
      fi

      # Upscale + grayscale: tesseract is far more accurate on ~300 DPI text
      # than on raw screen pixels.
      magick "$img" -colorspace gray -resize 300% -sharpen 0x1 png:- \
        | tesseract - - -l "$lang" --dpi 300 2>/dev/null \
        | sed -e 's/[[:space:]]*$//' > "$txt"

      if [ ! -s "$txt" ]; then
        notify-send -a "OCR" "OCR" "No text detected in the selection"
        exit 0
      fi

      # Already on the clipboard, the window is only there to grab a subset.
      wl-copy < "$txt"

      zenity --text-info \
        --title="OCR" \
        --font="monospace 11" \
        --width=800 --height=500 \
        --filename="$txt" \
        --ok-label="Close" --cancel-label="Close" >/dev/null 2>&1 || true
    '';
  };
in lib.mkIf (!config.remote) { home.packages = [ ocr-region ]; }
