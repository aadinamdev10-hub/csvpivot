package apps.csvpivot.util;

import java.util.*;

public class PivotResult {
    private List<String> rowFields = new ArrayList<>();
    private List<String> colFields = new ArrayList<>();
    private List<List<String>> rowTuples = new ArrayList<>();
    private List<List<String>> colTuples = new ArrayList<>();
    private Map<List<String>, Map<List<String>, Integer>> matrix = new HashMap<>();
    
    private Map<List<String>, Integer> rowTotals = new HashMap<>();
    private Map<List<String>, Integer> colTotals = new HashMap<>();
    private int grandTotal = 0;

    private Map<String, Integer> rowSpans = new HashMap<>();
    private Map<String, Integer> colSpans = new HashMap<>();

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

    public List<List<String>> getRowTuples() {
        return rowTuples;
    }

    public void setRowTuples(List<List<String>> rowTuples) {
        this.rowTuples = rowTuples;
    }

    public List<List<String>> getColTuples() {
        return colTuples;
    }

    public void setColTuples(List<List<String>> colTuples) {
        this.colTuples = colTuples;
    }

    public Map<List<String>, Map<List<String>, Integer>> getMatrix() {
        return matrix;
    }

    public void setMatrix(Map<List<String>, Map<List<String>, Integer>> matrix) {
        this.matrix = matrix;
    }

    public Map<List<String>, Integer> getRowTotals() {
        return rowTotals;
    }

    public void setRowTotals(Map<List<String>, Integer> rowTotals) {
        this.rowTotals = rowTotals;
    }

    public Map<List<String>, Integer> getColTotals() {
        return colTotals;
    }

    public void setColTotals(Map<List<String>, Integer> colTotals) {
        this.colTotals = colTotals;
    }

    public int getGrandTotal() {
        return grandTotal;
    }

    public void setGrandTotal(int grandTotal) {
        this.grandTotal = grandTotal;
    }

    public Map<String, Integer> getRowSpans() {
        return rowSpans;
    }

    public void setRowSpans(Map<String, Integer> rowSpans) {
        this.rowSpans = rowSpans;
    }

    public Map<String, Integer> getColSpans() {
        return colSpans;
    }

    public void setColSpans(Map<String, Integer> colSpans) {
        this.colSpans = colSpans;
    }

    public int getValue(List<String> rowTuple, List<String> colTuple) {
        if (matrix.containsKey(rowTuple)) {
            Map<List<String>, Integer> colMap = matrix.get(rowTuple);
            if (colMap != null && colMap.containsKey(colTuple)) {
                return colMap.get(colTuple);
            }
        }
        return 0;
    }

    public int getRowTotal(List<String> rowTuple) {
        return rowTotals.getOrDefault(rowTuple, 0);
    }

    public int getColTotal(List<String> colTuple) {
        return colTotals.getOrDefault(colTuple, 0);
    }
}
