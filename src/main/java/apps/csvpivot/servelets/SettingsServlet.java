package apps.csvpivot.servelets;

import apps.csvpivot.util.*;

import apps.csvpivot.util.DatasetDao;
import apps.csvpivot.util.PivotConfigDao;
import apps.csvpivot.util.PivotConfig;
import java.io.IOException;
import java.sql.SQLException;
import java.util.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet(urlPatterns = {"/apps/csvpivot/settings", "/apps/csvpivot/settings/save", "/apps/csvpivot/settings/delete", "/settings/save", "/settings/delete"})
public class SettingsServlet extends HttpServlet {
    private final DatasetDao datasetDao = new DatasetDao();
    private final PivotConfigDao pivotConfigDao = new PivotConfigDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        
        if (path != null && path.endsWith("/settings/delete")) {
            String configIdParam = request.getParameter("configId");
            if (configIdParam != null && !configIdParam.trim().isEmpty()) {
                try {
                    long configId = Long.parseLong(configIdParam);
                    pivotConfigDao.deleteConfig(configId);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
             response.sendRedirect(request.getContextPath() + "/apps/csvpivot/upload");
            return;
        }

        HttpSession session = request.getSession();
        String datasetIdParam = request.getParameter("datasetId");
        long datasetId = 0;
        if (datasetIdParam != null && !datasetIdParam.trim().isEmpty()) {
            try {
                datasetId = Long.parseLong(datasetIdParam);
                List<String> headers = datasetDao.getHeaders(datasetId);
                session.setAttribute("datasetId", datasetId);
                session.setAttribute("headers", headers);
            } catch (Exception e) {
                // Ignore and fallback to session
            }
        }

        if (datasetId == 0) {
            Long sessionDatasetId = (Long) session.getAttribute("datasetId");
            if (sessionDatasetId != null) {
                datasetId = sessionDatasetId;
            }
        }

        if (datasetId == 0) {
            response.sendRedirect(request.getContextPath() + "/apps/csvpivot/upload");
            return;
        }

        @SuppressWarnings("unchecked")
        List<String> headers = (List<String>) session.getAttribute("headers");
        if (headers == null || headers.isEmpty()) {
            try {
                headers = datasetDao.getHeaders(datasetId);
                session.setAttribute("headers", headers);
            } catch (SQLException e) {
                e.printStackTrace();
                response.sendRedirect(request.getContextPath() + "/apps/csvpivot/upload");
                return;
            }
        }

        request.getRequestDispatcher("/apps/csvpivot/settings.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        if (path == null || !path.endsWith("/settings/save")) {
            response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
            return;
        }

        HttpSession session = request.getSession();
        Long datasetId = null;
        String datasetIdParam = request.getParameter("datasetId");
        if (datasetIdParam != null && !datasetIdParam.trim().isEmpty()) {
            datasetId = Long.parseLong(datasetIdParam);
        }
        if (datasetId == null) {
            datasetId = (Long) session.getAttribute("datasetId");
        }

        if (datasetId == null) {
            response.sendRedirect(request.getContextPath() + "/apps/csvpivot/upload");
            return;
        }

        String configIdParam = request.getParameter("configId");
        Long configId = null;
        if (configIdParam != null && !configIdParam.trim().isEmpty()) {
            configId = Long.parseLong(configIdParam);
        }

        String configName = request.getParameter("configName");
        if (configName == null || configName.trim().isEmpty()) {
            configName = "Pivot Report - " + new Date().toString();
        }

        String[] rowFieldsArr = request.getParameterValues("rowField");
        String[] colFieldsArr = request.getParameterValues("colField");

        List<String> rowFields = new ArrayList<>();
        if (rowFieldsArr != null) {
            for (String rf : rowFieldsArr) {
                if (rf != null && !rf.trim().isEmpty() && !rf.equals("") && !rf.startsWith("--")) {
                    rowFields.add(rf.trim());
                }
            }
        }

        List<String> colFields = new ArrayList<>();
        if (colFieldsArr != null) {
            for (String cf : colFieldsArr) {
                if (cf != null && !cf.trim().isEmpty() && !cf.equals("") && !cf.startsWith("--")) {
                    colFields.add(cf.trim());
                }
            }
        }

        String aggType = request.getParameter("aggType");
        String aggField = request.getParameter("aggField");
        boolean hasAggTypeParam = (aggType != null);

        if (hasAggTypeParam) {
            if (aggType.trim().isEmpty()) {
                aggType = "COUNT";
            }
            if ("COUNT".equalsIgnoreCase(aggType)) {
                aggField = null;
            }
        } else {
            aggType = "COUNT";
            aggField = null;
        }

        String error = null;
        if (rowFields.isEmpty()) {
            error = "At least one Row Level must be selected.";
        } else if (colFields.isEmpty()) {
            error = "At least one Column Level must be selected.";
        } else {
            Set<String> intersection = new LinkedHashSet<>(rowFields);
            intersection.retainAll(colFields);
            if (!intersection.isEmpty()) {
                error = "The field(s) " + intersection + " cannot be used in both Row and Column levels simultaneously.";
            }
        }

        if (error != null) {
            request.setAttribute("error", error);
            request.setAttribute("selectedRowFields", rowFields);
            request.setAttribute("selectedColFields", colFields);
            request.setAttribute("configName", configName);
            request.setAttribute("aggType", aggType);
            request.setAttribute("aggField", aggField);
            request.getRequestDispatcher("/apps/csvpivot/settings.jsp").forward(request, response);
            return;
        }

        try {
            String scheme = request.getScheme();
            String serverName = request.getServerName();
            int serverPort = request.getServerPort();
            String contextPath = "/apps";
            StringBuilder urlBuilder = new StringBuilder();
            urlBuilder.append(scheme).append("://").append(serverName);
            if (("http".equals(scheme) && serverPort != 80) || ("https".equals(scheme) && serverPort != 443)) {
                urlBuilder.append(":").append(serverPort);
            }
            urlBuilder.append(contextPath);
            String baseUrl = urlBuilder.toString();

            if (configId != null) {
                // Update existing configuration
                PivotConfig config = pivotConfigDao.getConfig(configId);
                if (config != null) {
                    config.setName(configName.trim());
                    config.setRowFields(rowFields);
                    config.setColFields(colFields);
                    if (hasAggTypeParam) {
                        config.setAggType(aggType);
                        config.setAggField(aggField);
                    }
                    pivotConfigDao.updateConfig(config, baseUrl);
                    response.sendRedirect(request.getContextPath() + "/apps/csvpivot/report?configId=" + configId);
                    return;
                }
            }

            // Save new configuration
            PivotConfig config = new PivotConfig();
            config.setDatasetId(datasetId);
            config.setName(configName.trim());
            config.setRowFields(rowFields);
            config.setColFields(colFields);
            config.setAggType(aggType);
            config.setAggField(aggField);
            
            long newConfigId = pivotConfigDao.saveConfig(config, baseUrl);
            response.sendRedirect(request.getContextPath() + "/apps/csvpivot/report?configId=" + newConfigId);
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error while saving configuration: " + e.getMessage());
            request.setAttribute("selectedRowFields", rowFields);
            request.setAttribute("selectedColFields", colFields);
            request.setAttribute("configName", configName);
            request.setAttribute("aggType", aggType);
            request.setAttribute("aggField", aggField);
            request.getRequestDispatcher("/apps/csvpivot/settings.jsp").forward(request, response);
        }
    }
}