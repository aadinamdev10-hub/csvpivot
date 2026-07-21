package apps.csvpivot.util;

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

public class XlsxGenerator {

    public static void generate(PivotResult result, OutputStream out) throws IOException {
        try (ZipOutputStream zos = new ZipOutputStream(out)) {
            // 1. [Content_Types].xml
            zos.putNextEntry(new ZipEntry("[Content_Types].xml"));
            writeContentTypes(zos);
            zos.closeEntry();

            // 2. _rels/.rels
            zos.putNextEntry(new ZipEntry("_rels/.rels"));
            writeRootRels(zos);
            zos.closeEntry();

            // 3. xl/workbook.xml
            zos.putNextEntry(new ZipEntry("xl/workbook.xml"));
            writeWorkbook(zos);
            zos.closeEntry();

            // 4. xl/_rels/workbook.xml.rels
            zos.putNextEntry(new ZipEntry("xl/_rels/workbook.xml.rels"));
            writeWorkbookRels(zos);
            zos.closeEntry();

            // 5. xl/styles.xml
            zos.putNextEntry(new ZipEntry("xl/styles.xml"));
            writeStyles(zos);
            zos.closeEntry();

            // 6. xl/sheets/sheet1.xml (The actual sheet data)
            zos.putNextEntry(new ZipEntry("xl/sheets/sheet1.xml"));
            writeSheet1(result, zos);
            zos.closeEntry();
        }
    }

    private static void writeContentTypes(ZipOutputStream zos) throws IOException {
        String xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n" +
                "<Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\">\n" +
                "  <Default Extension=\"rels\" ContentType=\"application/vnd.openxmlformats-package.relationships+xml\"/>\n" +
                "  <Default Extension=\"xml\" ContentType=\"application/xml\"/>\n" +
                "  <Override PartName=\"/xl/workbook.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml\"/>\n" +
                "  <Override PartName=\"/xl/sheets/sheet1.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml\"/>\n" +
                "  <Override PartName=\"/xl/styles.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml\"/>\n" +
                "</Types>";
        zos.write(xml.getBytes(StandardCharsets.UTF_8));
    }

    private static void writeRootRels(ZipOutputStream zos) throws IOException {
        String xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n" +
                "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\">\n" +
                "  <Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument\" Target=\"xl/workbook.xml\"/>\n" +
                "</Relationships>";
        zos.write(xml.getBytes(StandardCharsets.UTF_8));
    }

    private static void writeWorkbook(ZipOutputStream zos) throws IOException {
        String xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n" +
                "<workbook xmlns=\"http://schemas.openxmlformats.org/spreadsheetml/2006/main\" xmlns:r=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships\">\n" +
                "  <sheets>\n" +
                "    <sheet name=\"Pivot Report\" sheetId=\"1\" r:id=\"rId1\"/>\n" +
                "  </sheets>\n" +
                "</workbook>";
        zos.write(xml.getBytes(StandardCharsets.UTF_8));
    }

    private static void writeWorkbookRels(ZipOutputStream zos) throws IOException {
        String xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n" +
                "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\">\n" +
                "  <Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet\" Target=\"sheets/sheet1.xml\"/>\n" +
                "  <Relationship Id=\"rId2\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles\" Target=\"styles.xml\"/>\n" +
                "</Relationships>";
        zos.write(xml.getBytes(StandardCharsets.UTF_8));
    }

    private static void writeStyles(ZipOutputStream zos) throws IOException {
        String xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n" +
                "<styleSheet xmlns=\"http://schemas.openxmlformats.org/spreadsheetml/2006/main\">\n" +
                "  <fonts count=\"3\">\n" +
                // Font 0: Normal (black, 11pt, Calibri)
                "    <font>\n" +
                "      <sz val=\"11\"/>\n" +
                "      <name val=\"Calibri\"/>\n" +
                "    </font>\n" +
                // Font 1: Bold White (for column headers on dark background)
                "    <font>\n" +
                "      <b/>\n" +
                "      <sz val=\"11\"/>\n" +
                "      <color rgb=\"FFFFFFFF\"/>\n" +
                "      <name val=\"Calibri\"/>\n" +
                "    </font>\n" +
                // Font 2: Bold Black (for row headers, totals - visible on light/white bg)
                "    <font>\n" +
                "      <b/>\n" +
                "      <sz val=\"11\"/>\n" +
                "      <name val=\"Calibri\"/>\n" +
                "    </font>\n" +
                "  </fonts>\n" +
                "  <fills count=\"5\">\n" +
                "    <fill><patternFill patternType=\"none\"/></fill>\n" +
                "    <fill><patternFill patternType=\"gray125\"/></fill>\n" +
                "    <fill><patternFill patternType=\"solid\"><fgColor rgb=\"FF1565C0\"/></patternFill></fill>\n" + // index 2: Blue header
                "    <fill><patternFill patternType=\"solid\"><fgColor rgb=\"FFE8F4FD\"/></patternFill></fill>\n" + // index 3: Light blue total
                "    <fill><patternFill patternType=\"solid\"><fgColor rgb=\"FFBBD6FB\"/></patternFill></fill>\n" + // index 4: Grand total
                "  </fills>\n" +
                "  <borders count=\"2\">\n" +
                "    <border/>\n" +
                "    <border>\n" +
                "      <left style=\"thin\"><color rgb=\"FFCBD5E1\"/></left>\n" +
                "      <right style=\"thin\"><color rgb=\"FFCBD5E1\"/></right>\n" +
                "      <top style=\"thin\"><color rgb=\"FFCBD5E1\"/></top>\n" +
                "      <bottom style=\"thin\"><color rgb=\"FFCBD5E1\"/></bottom>\n" +
                "    </border>\n" +
                "  </borders>\n" +
                "  <cellStyleXfs count=\"1\">\n" +
                "    <xf numFmtId=\"0\" fontId=\"0\" fillId=\"0\" borderId=\"0\"/>\n" +
                "  </cellStyleXfs>\n" +
                "  <cellXfs count=\"7\">\n" +
                // 0: Default plain cell
                "    <xf numFmtId=\"0\" fontId=\"0\" fillId=\"0\" borderId=\"0\"><alignment horizontal=\"left\"/></xf>\n" +
                // 1: Column Header (blue fill, WHITE bold font, centered)
                "    <xf numFmtId=\"0\" fontId=\"1\" fillId=\"2\" borderId=\"1\" applyFont=\"1\" applyFill=\"1\" applyBorder=\"1\" applyAlignment=\"1\"><alignment horizontal=\"center\" vertical=\"center\" wrapText=\"1\"/></xf>\n" +
                // 2: Row Header (no fill, DARK bold font, left aligned)
                "    <xf numFmtId=\"0\" fontId=\"2\" fillId=\"0\" borderId=\"1\" applyFont=\"1\" applyBorder=\"1\" applyAlignment=\"1\"><alignment horizontal=\"left\" vertical=\"center\" wrapText=\"1\"/></xf>\n" +
                // 3: Data Cell (normal font, right aligned, borders)
                "    <xf numFmtId=\"0\" fontId=\"0\" fillId=\"0\" borderId=\"1\" applyBorder=\"1\" applyAlignment=\"1\"><alignment horizontal=\"right\" vertical=\"center\"/></xf>\n" +
                // 4: Total row (light blue fill, DARK bold font, right aligned)
                "    <xf numFmtId=\"0\" fontId=\"2\" fillId=\"3\" borderId=\"1\" applyFont=\"1\" applyFill=\"1\" applyBorder=\"1\" applyAlignment=\"1\"><alignment horizontal=\"right\" vertical=\"center\"/></xf>\n" +
                // 5: Grand Total value cells (darker blue fill, DARK bold font, right aligned)
                "    <xf numFmtId=\"0\" fontId=\"2\" fillId=\"4\" borderId=\"1\" applyFont=\"1\" applyFill=\"1\" applyBorder=\"1\" applyAlignment=\"1\"><alignment horizontal=\"right\" vertical=\"center\"/></xf>\n" +
                // 6: Grand Total label cell (darker blue fill, DARK bold font, LEFT aligned)
                "    <xf numFmtId=\"0\" fontId=\"2\" fillId=\"4\" borderId=\"1\" applyFont=\"1\" applyFill=\"1\" applyBorder=\"1\" applyAlignment=\"1\"><alignment horizontal=\"left\" vertical=\"center\"/></xf>\n" +
                "  </cellXfs>\n" +
                "</styleSheet>";

        zos.write(xml.getBytes(StandardCharsets.UTF_8));
    }

    private static void writeSheet1(PivotResult result, ZipOutputStream zos) throws IOException {
        Writer writer = new OutputStreamWriter(zos, StandardCharsets.UTF_8);
        writer.write("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n");
        writer.write("<worksheet xmlns=\"http://schemas.openxmlformats.org/spreadsheetml/2006/main\">\n");
        
        // Define column widths roughly
        writer.write("  <cols>\n");
        writer.write("    <col min=\"1\" max=\"1\" width=\"8\" customWidth=\"1\"/>\n");  // Sr. No.
        writer.write("    <col min=\"2\" max=\"3\" width=\"20\" customWidth=\"1\"/>\n");
        writer.write("    <col min=\"4\" max=\"25\" width=\"12\" customWidth=\"1\"/>\n");
        writer.write("  </cols>\n");

        writer.write("  <sheetData>\n");

        List<String> mergeCells = new ArrayList<>();
        int rowFieldsSize = result.getRowFields().size();
        int colFieldsSize = result.getColFields().size();
        
        int excelRowIndex = 1;

        // 1. Column Headers rendering
        for (int l = 0; l < colFieldsSize; l++) {
            writer.write("    <row r=\"" + excelRowIndex + "\" ht=\"25\">\n");

            // Sr. No. header cell (only in first header row, spans all col-header rows)
            if (l == 0) {
                writeCell(writer, getExcelRef(0, excelRowIndex), "Sr. No.", 1);
                if (colFieldsSize > 1) {
                    mergeCells.add(getExcelRef(0, excelRowIndex) + ":" + getExcelRef(0, excelRowIndex + colFieldsSize - 1));
                }
            }

            // Corner top-left cell (shifted right by 1 for Sr. No.)
            if (l == 0) {
                // Header fields merge
                StringBuilder sb = new StringBuilder();
                for (int f = 0; f < rowFieldsSize; f++) {
                    sb.append(result.getRowFields().get(f));
                    if (f < rowFieldsSize - 1) sb.append(" > ");
                }
                
                writeCell(writer, getExcelRef(1, excelRowIndex), sb.toString(), 1); // Header style
                if (rowFieldsSize > 1 || colFieldsSize > 1) {
                    mergeCells.add(getExcelRef(1, excelRowIndex) + ":" + getExcelRef(rowFieldsSize, excelRowIndex + colFieldsSize - 1));
                }
            }
            
            // Render columns
            for (int c = 0; c < result.getColTuples().size(); c++) {
                List<String> colTuple = result.getColTuples().get(c);
                String val = colTuple.get(l);
                String spanKey = l + "," + c;
                int span = result.getColSpans().getOrDefault(spanKey, 0);

                int targetCol = rowFieldsSize + 1 + c;
                if (span > 0) {
                    writeCell(writer, getExcelRef(targetCol, excelRowIndex), val, 1); // Header style
                    if (span > 1) {
                        mergeCells.add(getExcelRef(targetCol, excelRowIndex) + ":" + getExcelRef(targetCol + span - 1, excelRowIndex));
                    }
                }
            }

            // Grand Total Header Column
            if (l == 0) {
                int targetCol = rowFieldsSize + 1 + result.getColTuples().size();
                writeCell(writer, getExcelRef(targetCol, excelRowIndex), "Grand Total", 1); // Header style
                if (colFieldsSize > 1) {
                    mergeCells.add(getExcelRef(targetCol, excelRowIndex) + ":" + getExcelRef(targetCol, excelRowIndex + colFieldsSize - 1));
                }
            }

            writer.write("    </row>\n");
            excelRowIndex++;
        }

        // 2. Data Rows rendering
        for (int r = 0; r < result.getRowTuples().size(); r++) {
            List<String> rowTuple = result.getRowTuples().get(r);
            writer.write("    <row r=\"" + excelRowIndex + "\" ht=\"20\">\n");

            // Sr. No. cell
            writeNumberCell(writer, getExcelRef(0, excelRowIndex), r + 1, 2); // bold left style

            // Row header labels (shifted by 1 for Sr. No.)
            for (int f = 0; f < rowFieldsSize; f++) {
                String val = rowTuple.get(f);
                String spanKey = r + "," + f;
                int span = result.getRowSpans().getOrDefault(spanKey, 0);

                if (span > 0) {
                    writeCell(writer, getExcelRef(f + 1, excelRowIndex), val, 2); // Row Header Style
                    if (span > 1) {
                        mergeCells.add(getExcelRef(f + 1, excelRowIndex) + ":" + getExcelRef(f + 1, excelRowIndex + span - 1));
                    }
                }
            }

            // Metric Counts cells
            for (int c = 0; c < result.getColTuples().size(); c++) {
                List<String> colTuple = result.getColTuples().get(c);
                int val = result.getValue(rowTuple, colTuple);
                int targetCol = rowFieldsSize + 1 + c;
                writeNumberCell(writer, getExcelRef(targetCol, excelRowIndex), val, 3);
            }

            // Row Total cell
            int rowTotal = result.getRowTotal(rowTuple);
            int totalCol = rowFieldsSize + 1 + result.getColTuples().size();
            writeNumberCell(writer, getExcelRef(totalCol, excelRowIndex), rowTotal, 4);

            writer.write("    </row>\n");
            excelRowIndex++;
        }

        // 3. Grand Total Bottom Row
        writer.write("    <row r=\"" + excelRowIndex + "\" ht=\"22\">\n");
        // Sr. No. blank for Grand Total row
        writeCell(writer, getExcelRef(0, excelRowIndex), "", 6);
        // Grand Total Label
        writeCell(writer, getExcelRef(1, excelRowIndex), "Grand Total", 6);
        if (rowFieldsSize > 1) {
            mergeCells.add(getExcelRef(1, excelRowIndex) + ":" + getExcelRef(rowFieldsSize, excelRowIndex));
        }

        // Col totals
        for (int c = 0; c < result.getColTuples().size(); c++) {
            List<String> colTuple = result.getColTuples().get(c);
            int colTotal = result.getColTotal(colTuple);
            int targetCol = rowFieldsSize + 1 + c;
            writeNumberCell(writer, getExcelRef(targetCol, excelRowIndex), colTotal, 4);
        }

        // Overall Grand Total
        int finalTotal = result.getGrandTotal();
        int finalCol = rowFieldsSize + 1 + result.getColTuples().size();
        writeNumberCell(writer, getExcelRef(finalCol, excelRowIndex), finalTotal, 5);

        writer.write("    </row>\n");

        writer.write("  </sheetData>\n");

        // Merge range declarations
        if (!mergeCells.isEmpty()) {
            writer.write("  <mergeCells count=\"" + mergeCells.size() + "\">\n");
            for (String range : mergeCells) {
                writer.write("    <mergeCell ref=\"" + range + "\"/>\n");
            }
            writer.write("  </mergeCells>\n");
        }

        writer.write("</worksheet>");
        writer.flush();
    }

    private static void writeCell(Writer writer, String ref, String val, int styleIndex) throws IOException {
        writer.write("      <c r=\"" + ref + "\" s=\"" + styleIndex + "\" t=\"inlineStr\">\n");
        writer.write("        <is><t>" + escapeXml(val) + "</t></is>\n");
        writer.write("      </c>\n");
    }

    private static void writeNumberCell(Writer writer, String ref, int val, int styleIndex) throws IOException {
        writer.write("      <c r=\"" + ref + "\" s=\"" + styleIndex + "\">\n");
        writer.write("        <v>" + val + "</v>\n");
        writer.write("      </c>\n");
    }

    private static String getExcelRef(int colIndex, int rowIndex) {
        return getColName(colIndex) + rowIndex;
    }

    private static String getColName(int col) {
        StringBuilder sb = new StringBuilder();
        while (col >= 0) {
            sb.insert(0, (char) ('A' + (col % 26)));
            col = (col / 26) - 1;
        }
        return sb.toString();
    }

    private static String escapeXml(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&apos;");
    }
}