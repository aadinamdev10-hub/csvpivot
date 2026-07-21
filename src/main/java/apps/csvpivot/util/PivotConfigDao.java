package apps.csvpivot.util;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PivotConfigDao {
    private static final Gson gson = new Gson();

    public long saveConfig(PivotConfig config, String baseUrl) throws SQLException {
        String sql = "INSERT INTO pivot_config (dataset_id, name, agg_type, agg_field, row_fields_json, col_fields_json, share_link) VALUES (?, ?, ?, ?, ?, ?, ?)";
        String rowFieldsJson = gson.toJson(config.getRowFields());
        String colFieldsJson = gson.toJson(config.getColFields());

        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setLong(1, config.getDatasetId());
            ps.setString(2, config.getName());
            ps.setString(3, config.getAggType());
            ps.setString(4, config.getAggField());
            ps.setString(5, rowFieldsJson);
            ps.setString(6, colFieldsJson);
            ps.setString(7, config.getShareLink());
            
            ps.executeUpdate();
            
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    long id = rs.getLong(1);
                    config.setId(id);
                    
                    if (config.getShareLink() == null || config.getShareLink().trim().isEmpty() || !config.getShareLink().startsWith("http")) {
                        String generatedLink = baseUrl + "/report?configId=" + id + "&view=user";
                        config.setShareLink(generatedLink);
                        try (PreparedStatement updatePs = conn.prepareStatement("UPDATE pivot_config SET share_link = ? WHERE id = ?")) {
                            updatePs.setString(1, generatedLink);
                            updatePs.setLong(2, id);
                            updatePs.executeUpdate();
                        }
                    }
                    
                    return id;
                }
            }
        }
        throw new SQLException("Failed to save pivot configuration, no ID obtained.");
    }

    public PivotConfig getConfig(long configId) throws SQLException {
        String sql = "SELECT * FROM pivot_config WHERE id = ?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, configId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    PivotConfig config = new PivotConfig();
                    config.setId(rs.getLong("id"));
                    config.setDatasetId(rs.getLong("dataset_id"));
                    config.setName(rs.getString("name"));
                    config.setAggType(rs.getString("agg_type"));
                    config.setAggField(rs.getString("agg_field"));
                    config.setShareLink(rs.getString("share_link"));
                    
                    String rowFieldsJson = rs.getString("row_fields_json");
                    String colFieldsJson = rs.getString("col_fields_json");
                    
                    List<String> rowFields = gson.fromJson(rowFieldsJson, new TypeToken<List<String>>(){}.getType());
                    List<String> colFields = gson.fromJson(colFieldsJson, new TypeToken<List<String>>(){}.getType());
                    
                    config.setRowFields(rowFields != null ? rowFields : new ArrayList<>());
                    config.setColFields(colFields != null ? colFields : new ArrayList<>());
                    
                    return config;
                }
            }
        }
        return null;
    }

    public List<PivotConfig> getAllConfigs() throws SQLException {
        List<PivotConfig> configs = new ArrayList<>();
        String sql = "SELECT pc.id, pc.dataset_id, pc.name, pc.agg_type, pc.agg_field, pc.row_fields_json, pc.col_fields_json, pc.created_at, pc.share_link, d.original_filename " +
                     "FROM pivot_config pc " +
                     "JOIN dataset d ON pc.dataset_id = d.id " +
                     "ORDER BY pc.created_at DESC";
        
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                PivotConfig config = new PivotConfig();
                config.setId(rs.getLong("id"));
                config.setDatasetId(rs.getLong("dataset_id"));
                config.setName(rs.getString("name"));
                config.setAggType(rs.getString("agg_type"));
                config.setAggField(rs.getString("agg_field"));
                config.setDatasetFilename(rs.getString("original_filename"));
                config.setCreatedAt(rs.getString("created_at"));
                config.setShareLink(rs.getString("share_link"));
                
                String rowFieldsJson = rs.getString("row_fields_json");
                String colFieldsJson = rs.getString("col_fields_json");
                
                List<String> rowFields = gson.fromJson(rowFieldsJson, new TypeToken<List<String>>(){}.getType());
                List<String> colFields = gson.fromJson(colFieldsJson, new TypeToken<List<String>>(){}.getType());
                
                config.setRowFields(rowFields != null ? rowFields : new ArrayList<>());
                config.setColFields(colFields != null ? colFields : new ArrayList<>());
                
                configs.add(config);
            }
        }
        return configs;
    }

    public void updateConfig(PivotConfig config, String baseUrl) throws SQLException {
        if (config.getShareLink() == null || config.getShareLink().trim().isEmpty() || !config.getShareLink().startsWith("http")) {
            config.setShareLink(baseUrl + "/report?configId=" + config.getId() + "&view=user");
        }
        String sql = "UPDATE pivot_config SET name = ?, agg_type = ?, agg_field = ?, row_fields_json = ?, col_fields_json = ?, share_link = ? WHERE id = ?";
        String rowFieldsJson = gson.toJson(config.getRowFields());
        String colFieldsJson = gson.toJson(config.getColFields());
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, config.getName());
            ps.setString(2, config.getAggType() != null ? config.getAggType() : "COUNT");
            ps.setString(3, config.getAggField()); // null is fine for COUNT
            ps.setString(4, rowFieldsJson);
            ps.setString(5, colFieldsJson);
            ps.setString(6, config.getShareLink());
            ps.setLong(7, config.getId());
            ps.executeUpdate();
        }
    }

    public void deleteConfig(long configId) throws SQLException {
        String sql = "DELETE FROM pivot_config WHERE id = ?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, configId);
            ps.executeUpdate();
        }
    }
}