package apps.csvpivot.util;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DatasetDao {
    private static final Gson gson = new Gson();

    public long saveDataset(String filename, List<String> headers, String csvContent) throws SQLException {
        String sql = "INSERT INTO dataset (original_filename, headers_json, csv_content) VALUES (?, ?, ?)";
        String headersJson = gson.toJson(headers);
        
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setString(1, filename);
            ps.setString(2, headersJson);
            ps.setString(3, csvContent);
            
            ps.executeUpdate();
            
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getLong(1);
                }
            }
        }
        throw new SQLException("Failed to save dataset, no ID obtained.");
    }

    public List<String> getHeaders(long datasetId) throws SQLException {
        String sql = "SELECT headers_json FROM dataset WHERE id = ?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, datasetId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String headersJson = rs.getString("headers_json");
                    return gson.fromJson(headersJson, new TypeToken<List<String>>(){}.getType());
                }
            }
        }
        return new ArrayList<>();
    }

    public String getDatasetContent(long datasetId) throws SQLException {
        String sql = "SELECT csv_content FROM dataset WHERE id = ?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, datasetId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("csv_content");
                }
            }
        }
        return null;
    }
}
