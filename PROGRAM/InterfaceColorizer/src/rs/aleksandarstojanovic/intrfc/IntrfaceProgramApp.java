package rs.aleksandarstojanovic.intrfc;

import java.awt.Color;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.imageio.ImageIO;

/**
 * A program that generates color variants (BLUE, GREEN, RED, and WHITE) of
 * input images. The input images are processed to replace specific magenta-like
 * colors with the target colors.
 *
 * Input Directory: INTRFACE_SOURCE Output Directory: PRODUCTION
 *
 * Each color variant is stored in its respective subdirectory.
 *
 * @author Alexander Stojanovich <coas91@rocketmail.com>
 */
public class IntrfaceProgramApp {

    // Predefined color constants for output variants
    private static final Color BLUE_COLOR = new Color(34, 80, 128);
    private static final Color GREEN_COLOR = new Color(0, 243, 0);
    private static final Color HK_COLOR = new Color(255, 255, 255); // Placeholder for potential customization

    // Directories for input and output files
    private static final String inDir = "C:\\Users\\coas9\\GitHub\\FOnline2S3_GRAPHITE_INTRFACE\\INTRFACE_SOURCE";
    private static final String outDir = "C:\\Users\\coas9\\GitHub\\FOnline2S3_GRAPHITE_INTRFACE\\INTRFACE_PRODUCTION_CLK";

    // Luminance coefficients based on the Rec. 709 standard
    private static final float LUMA_RED_COEFF = 0.299f;
    private static final float LUMA_GREEN_COEFF = 0.587f;
    private static final float LUMA_BLUE_COEFF = 0.114f;

    /**
     * The main method processes input images and generates color variants.
     *
     * @param args command-line arguments (not used).
     */
    public static void main(String[] args) {
        // Output color names and corresponding colors
        String[] colorName = {"BLUE", "GREEN", "RED", "WHITE"};
        Color[] colors = {BLUE_COLOR, GREEN_COLOR, Color.RED, Color.WHITE};

        // Subdirectory names under input directory (currently unused)
        final String[] subDirs = {"clock_x"}; // Example: {"", "IFACE", "MainScreen", "Other", "WorldMap"};

        // Ensure input and output directories exist
        File inDirFile = new File(inDir);
        File outDirFile = new File(outDir);

        for (int i = 0; i < colors.length; i++) {
            // Create output subdirectory for each color
            File colorDir = new File(outDirFile, colorName[i]);
            if (!colorDir.exists()) {
                colorDir.mkdirs();
            }

            if (inDirFile.exists()) {
                for (String subDir : subDirs) {
                    File subDirFile = new File(inDirFile, subDir);

                    // Process PNG files in the subdirectory
                    for (File inputFile : subDirFile.listFiles()) {
                        if (inputFile.getName().toLowerCase().endsWith(".png")) {
                            try {
                                // Read the input image
                                BufferedImage img = ImageIO.read(inputFile);

                                // Process each pixel in the image
                                for (int px = 0; px < img.getWidth(); px++) {
                                    for (int py = 0; py < img.getHeight(); py++) {
                                        Color pixCol = new Color(img.getRGB(px, py), true);
                                        boolean isMagentaLike = false;

                                        // Detect magenta-like colors using thresholds
                                        for (int k = 1; k <= 10; k++) {
                                            boolean condition1 = pixCol.getRed() * k >= 25 && pixCol.getGreen() * k < 5 && pixCol.getBlue() * k >= 25;
                                            boolean condition2 = pixCol.getGreen() < 50 && pixCol.getRed() >= 75 && pixCol.getBlue() >= 75;
                                            if (condition1 || condition2) {
                                                isMagentaLike = true;
                                                break;
                                            }
                                        }

                                        if (isMagentaLike) {
                                            // Calculate luminance of the pixel
                                            float luma = (pixCol.getRed() * LUMA_RED_COEFF + pixCol.getGreen() * LUMA_GREEN_COEFF + pixCol.getBlue() * LUMA_BLUE_COEFF) / 255.0f;
                                            float k = (float) Math.expm1(2.4 * luma);

                                            // Generate new color based on target color and luminance
                                            int outRed = Math.min(Math.max(Math.round(k * colors[i].getRed()), 0), 255);
                                            int outGreen = Math.min(Math.max(Math.round(k * colors[i].getGreen()), 0), 255);
                                            int outBlue = Math.min(Math.max(Math.round(k * colors[i].getBlue()), 0), 255);
                                            int outAlpha = pixCol.getAlpha();
                                            Color outCol = new Color(outRed, outGreen, outBlue, outAlpha);

                                            img.setRGB(px, py, outCol.getRGB());
                                        }
                                    }
                                }

                                // Write the processed image to the output directory
                                File outputFile = new File(colorDir, inputFile.getName());
                                ImageIO.write(img, "png", outputFile);
                                System.out.println("Processed: " + outputFile.getAbsolutePath());

                            } catch (IOException ex) {
                                Logger.getLogger(IntrfaceProgramApp.class.getName()).log(Level.SEVERE, "Error processing file: " + inputFile.getName(), ex);
                            }
                        }
                    }
                }
            }
        }
    }
}
