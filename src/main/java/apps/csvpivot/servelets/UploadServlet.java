package apps.csvpivot.servelets;

import apps.csvpivot.util.*;

import apps.csvpivot.util.DatasetDao;
import apps.csvpivot.util.CsvParserService;
import apps.csvpivot.util.PivotConfigDao;
import apps.csvpivot.util.PivotConfig;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet(urlPatterns = {"/apps/csvpivot/upload", "/upload"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 10,      // 10MB
    maxRequestSize = 1024 * 1024 * 50    // 50MB
)
public class UploadServlet extends HttpServlet {
    private final DatasetDao datasetDao = new DatasetDao();
    private final PivotConfigDao pivotConfigDao = new PivotConfigDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            List<PivotConfig> savedConfigs = pivotConfigDao.getAllConfigs();
            request.setAttribute("savedConfigs", savedConfigs);
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("dbError", "Could not load saved configurations: " + e.getMessage());
        }
        request.getRequestDispatcher("/apps/csvpivot/upload.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            Part filePart = request.getPart("csvFile");
            if (filePart == null || filePart.getSize() == 0) {
                // Ensure savedConfigs are populated on redirect/refresh error
                refreshSavedConfigs(request);
                request.setAttribute("error", "Please select a valid CSV file to upload.");
                request.getRequestDispatcher("/apps/csvpivot/upload.jsp").forward(request, response);
                return;
            }

            String filename = filePart.getSubmittedFileName();
            if (filename == null || !filename.toLowerCase().endsWith(".csv")) {
                refreshSavedConfigs(request);
                request.setAttribute("error", "Only CSV files (.csv) are supported.");
                request.getRequestDispatcher("/apps/csvpivot/upload.jsp").forward(request, response);
                return;
            }

            String csvContent;
            try (InputStream is = filePart.getInputStream()) {
                csvContent = new String(is.readAllBytes(), StandardCharsets.UTF_8);
            }

            CsvParserService.CsvData csvData;
            try {
                csvData = CsvParserService.parse(csvContent);
            } catch (Exception e) {
                refreshSavedConfigs(request);
                request.setAttribute("error", "Failed to parse CSV: " + e.getMessage());
                request.getRequestDispatcher("/apps/csvpivot/upload.jsp").forward(request, response);
                return;
            }

            long datasetId;
            try {
                datasetId = datasetDao.saveDataset(filename, csvData.getHeaders(), csvContent);
            } catch (SQLException e) {
                e.printStackTrace();
                refreshSavedConfigs(request);
                request.setAttribute("error", "Database error while saving dataset: " + e.getMessage());
                request.getRequestDispatcher("/apps/csvpivot/upload.jsp").forward(request, response);
                return;
            }

            HttpSession session = request.getSession();
            session.setAttribute("datasetId", datasetId);
            session.setAttribute("headers", csvData.getHeaders());
            session.setAttribute("filename", filename);

            response.sendRedirect(request.getContextPath() + "/apps/csvpivot/settings");

        } catch (Exception e) {
            e.printStackTrace();
            refreshSavedConfigs(request);
            request.setAttribute("error", "An unexpected error occurred: " + e.getMessage());
            request.getRequestDispatcher("/apps/csvpivot/upload.jsp").forward(request, response);
        }
    }

    private void refreshSavedConfigs(HttpServletRequest request) {
        try {
            List<PivotConfig> savedConfigs = pivotConfigDao.getAllConfigs();
            request.setAttribute("savedConfigs", savedConfigs);
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}