package apps.csvpivot.util;

import java.util.ArrayList;
import java.util.List;

public class PivotConfig {
    private long id;
    private long datasetId;
    private String name;
    private String aggType = "COUNT";
    private String aggField;
    private List<String> rowFields = new ArrayList<>();
    private List<String> colFields = new ArrayList<>();
    
    // UI fields for listings
    private String datasetFilename;
    private String createdAt;
    
    // Stored share link column
    private String shareLink;

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public long getDatasetId() {
        return datasetId;
    }

    public void setDatasetId(long datasetId) {
        this.datasetId = datasetId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getAggType() {
        return aggType;
    }

    public void setAggType(String aggType) {
        this.aggType = aggType;
    }

    public String getAggField() {
        return aggField;
    }

    public void setAggField(String aggField) {
        this.aggField = aggField;
    }

    public List<String> getRowFields() {
        return rowFields;
    }

    public void setRowFields(List<String> rowFields) {
        this.rowFields = rowFields;
    }

    public List<String> getColFields() {
        return colFields;
    }

    public void setColFields(List<String> colFields) {
        this.colFields = colFields;
    }

    public String getDatasetFilename() {
        return datasetFilename;
    }

    public void setDatasetFilename(String datasetFilename) {
        this.datasetFilename = datasetFilename;
    }

    public String getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(String createdAt) {
        this.createdAt = createdAt;
    }

    public String getShareLink() {
        return shareLink;
    }

    public void setShareLink(String shareLink) {
        this.shareLink = shareLink;
    }
}
