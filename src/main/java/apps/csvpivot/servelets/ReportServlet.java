package apps.csvpivot.servelets;

import apps.csvpivot.util.*;

import apps.csvpivot.util.DatasetDao;
import apps.csvpivot.util.PivotConfigDao;
import apps.csvpivot.util.PivotConfig;
import apps.csvpivot.util.PivotResult;
import apps.csvpivot.util.CsvParserService;
import apps.csvpivot.util.PivotEngine;
import apps.csvpivot.util.XlsxGenerator;
import java.io.IOException;
import java.io.OutputStream;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet(urlPatterns = {"/apps/csvpivot/report", "/report"})
public class ReportServlet extends HttpServlet {
    private final PivotConfigDao pivotConfigDao = new PivotConfigDao();
    private final DatasetDao datasetDao = new DatasetDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String configIdParam = request.getParameter("configId");
        if (configIdParam == null || configIdParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/apps/csvpivot/upload");
            return;
        }

        try {
            long configId = Long.parseLong(configIdParam);
            PivotConfig config = pivotConfigDao.getConfig(configId);
            if (config == null) {
                request.setAttribute("error", "Pivot configuration with ID " + configId + " not found.");
                request.getRequestDispatcher("/apps/csvpivot/upload.jsp").forward(request, response);
                return;
            }

            String csvContent = datasetDao.getDatasetContent(config.getDatasetId());
            if (csvContent == null || csvContent.isEmpty()) {
                request.setAttribute("error", "Dataset content not found for configuration.");
                request.getRequestDispatcher("/apps/csvpivot/upload.jsp").forward(request, response);
                return;
            }

            CsvParserService.CsvData csvData = CsvParserService.parse(csvContent);
            PivotResult result = PivotEngine.pivot(
                csvData.getRows(),
                config.getRowFields(),
                config.getColFields(),
                config.getAggType(),
                config.getAggField()
            );

            request.setAttribute("pivotResult", result);
            request.setAttribute("config", config);
            request.setAttribute("headers", csvData.getHeaders());
            
            String view = request.getParameter("view");
            boolean isUserView = "user".equalsIgnoreCase(view);
            request.setAttribute("isUserView", isUserView);
            
            String filename = null;
            HttpSession session = request.getSession(false);
            if (session != null) {
                filename = (String) session.getAttribute("filename");
            }
            if (filename == null) {
                filename = "Dataset #" + config.getDatasetId();
            }
            request.setAttribute("filename", filename);

            String export = request.getParameter("export");
            if ("excel".equalsIgnoreCase(export)) {
                response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
                response.setHeader("Content-Disposition", "attachment; filename=\"pivot_report_" + configId + ".xlsx\"");
                try (OutputStream os = response.getOutputStream()) {
                    XlsxGenerator.generate(result, os);
                }
            } else if ("csv".equalsIgnoreCase(export)) {
                response.setContentType("text/csv; charset=UTF-8");
                response.setHeader("Content-Disposition", "attachment; filename=\"pivot_report_" + configId + ".csv\"");
                String csvDataString = generateCsvData(result);
                response.getWriter().write(csvDataString);
            } else {
                request.getRequestDispatcher("/apps/csvpivot/report.jsp").forward(request, response);
            }

        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid configuration ID format.");
            request.getRequestDispatcher("/apps/csvpivot/upload.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Failed to generate report: " + e.getMessage());
            request.getRequestDispatcher("/apps/csvpivot/upload.jsp").forward(request, response);
        }
    }

    private String generateCsvData(PivotResult result) {
        StringBuilder sb = new StringBuilder();
        int rowFieldsSize = result.getRowFields().size();
        int colFieldsSize = result.getColFields().size();

        // 1. Column headers — Sr. No. in first column, then row fields, then col tuples
        for (int l = 0; l < colFieldsSize; l++) {
            if (l == 0) {
                sb.append("\"Sr. No.\",");
                for (int f = 0; f < rowFieldsSize; f++) {
                    sb.append("\"").append(result.getRowFields().get(f)).append("\"").append(",");
                }
            } else {
                // blank Sr. No. + blank row field columns for level rows beyond first
                for (int f = 0; f <= rowFieldsSize; f++) {
                    sb.append(",");
                }
            }

            for (int c = 0; c < result.getColTuples().size(); c++) {
                List<String> colTuple = result.getColTuples().get(c);
                String spanKey = l + "," + c;
                int span = result.getColSpans().getOrDefault(spanKey, 0);
                if (span > 0) {
                    sb.append("\"").append(colTuple.get(l)).append("\"");
                }
                sb.append(",");
            }

            if (l == 0) {
                sb.append("\"Grand Total\"");
            }
            sb.append("\n");
        }

        // 2. Data rows — Sr. No. first
        for (int r = 0; r < result.getRowTuples().size(); r++) {
            List<String> rowTuple = result.getRowTuples().get(r);
            sb.append(r + 1).append(",");   // Sr. No.
            for (int f = 0; f < rowFieldsSize; f++) {
                String spanKey = r + "," + f;
                int span = result.getRowSpans().getOrDefault(spanKey, 0);
                if (span > 0) {
                    sb.append("\"").append(rowTuple.get(f)).append("\"");
                }
                sb.append(",");
            }

            for (int c = 0; c < result.getColTuples().size(); c++) {
                List<String> colTuple = result.getColTuples().get(c);
                int val = result.getValue(rowTuple, colTuple);
                sb.append(val).append(",");
            }

            sb.append(result.getRowTotal(rowTuple)).append("\n");
        }

        // 3. Grand Total row — blank Sr. No.
        sb.append(",");   // blank Sr. No.
        sb.append("\"Grand Total\"");
        for (int f = 1; f < rowFieldsSize; f++) {
            sb.append(",");
        }
        sb.append(",");

        for (int c = 0; c < result.getColTuples().size(); c++) {
            List<String> colTuple = result.getColTuples().get(c);
            sb.append(result.getColTotal(colTuple)).append(",");
        }
        sb.append(result.getGrandTotal()).append("\n");

        return sb.toString();
    }
}