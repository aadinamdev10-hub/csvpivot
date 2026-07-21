package apps.csvpivot.util;

import java.util.*;

public class PivotEngine {

    public static PivotResult pivot(List<Map<String, String>> data, List<String> rowFields, List<String> colFields, String aggType, String aggField) {
        if (data == null || rowFields == null || colFields == null) {
            throw new IllegalArgumentException("Inputs to PivotEngine cannot be null");
        }
        if (rowFields.isEmpty()) {
            throw new IllegalArgumentException("At least one Row Level must be specified");
        }
        if (colFields.isEmpty()) {
            throw new IllegalArgumentException("At least one Column Level must be specified");
        }

        PivotResult result = new PivotResult();
        result.setRowFields(new ArrayList<>(rowFields));
        result.setColFields(new ArrayList<>(colFields));
        // Step 1: Compute dynamic outlier length fences and collect distinct values for row fields
        Map<String, Double> rowFences = new HashMap<>();
        List<Set<String>> distinctValuesPerRowField = new ArrayList<>();
        for (String field : rowFields) {
            List<Integer> lengths = new ArrayList<>();
            for (Map<String, String> row : data) {
                String v = row.get(field);
                if (v != null && !v.trim().isEmpty() && !v.trim().equalsIgnoreCase("(blank)")) {
                    lengths.add(v.trim().length());
                }
            }
            Collections.sort(lengths);
            double maxLen = Double.MAX_VALUE;
            int n = lengths.size();
            if (n >= 4) {
                double q1 = lengths.get(n / 4);
                double q3 = lengths.get((3 * n) / 4);
                double iqr = q3 - q1;
                if (iqr > 0) {
                    maxLen = q3 + 1.5 * iqr;
                } else if (q3 > 0) {
                    maxLen = q3 * 3.0;
                }
            }
            rowFences.put(field, maxLen);

            // Collect distinct non-blank, non-outlier values for this row field
            Set<String> values = new TreeSet<>();
            for (Map<String, String> row : data) {
                String val = row.get(field);
                if (val != null && !val.trim().isEmpty() && !val.trim().equalsIgnoreCase("(blank)") && (val.trim().length() <= 50 || val.trim().length() <= maxLen)) {
                    values.add(val.trim());
                }
            }
            distinctValuesPerRowField.add(values);
        }

        List<List<String>> sortedRowTuples = new ArrayList<>();
        generateCartesian(distinctValuesPerRowField, 0, new ArrayList<>(), sortedRowTuples);

        // Step 2: Compute dynamic outlier length fences and collect distinct values for column fields
        Map<String, Double> colFences = new HashMap<>();
        List<Set<String>> distinctValuesPerColField = new ArrayList<>();
        for (String field : colFields) {
            List<Integer> lengths = new ArrayList<>();
            for (Map<String, String> row : data) {
                String v = row.get(field);
                if (v != null && !v.trim().isEmpty() && !v.trim().equalsIgnoreCase("(blank)")) {
                    lengths.add(v.trim().length());
                }
            }
            Collections.sort(lengths);
            double maxLen = Double.MAX_VALUE;
            int n = lengths.size();
            if (n >= 4) {
                double q1 = lengths.get(n / 4);
                double q3 = lengths.get((3 * n) / 4);
                double iqr = q3 - q1;
                if (iqr > 0) {
                    maxLen = q3 + 1.5 * iqr;
                } else if (q3 > 0) {
                    maxLen = q3 * 3.0;
                }
            }
            colFences.put(field, maxLen);

            // Collect distinct non-blank, non-outlier values for this column field
            Set<String> values = new TreeSet<>();
            for (Map<String, String> row : data) {
                String val = row.get(field);
                if (val != null && !val.trim().isEmpty() && !val.trim().equalsIgnoreCase("(blank)") && (val.trim().length() <= 50 || val.trim().length() <= maxLen)) {
                    values.add(val.trim());
                }
            }
            distinctValuesPerColField.add(values);
        }

        List<List<String>> sortedColTuples = new ArrayList<>();
        generateCartesian(distinctValuesPerColField, 0, new ArrayList<>(), sortedColTuples);

        Comparator<List<String>> tupleComparator = (t1, t2) -> {
            for (int i = 0; i < Math.min(t1.size(), t2.size()); i++) {
                int cmp = t1.get(i).compareTo(t2.get(i));
                if (cmp != 0) return cmp;
            }
            return Integer.compare(t1.size(), t2.size());
        };

        Collections.sort(sortedRowTuples, tupleComparator);
        Collections.sort(sortedColTuples, tupleComparator);

        result.setRowTuples(sortedRowTuples);
        result.setColTuples(sortedColTuples);

        Map<List<String>, Map<List<String>, Integer>> matrix = new HashMap<>();
        Map<List<String>, Integer> rowTotals = new HashMap<>();
        Map<List<String>, Integer> colTotals = new HashMap<>();
        int grandTotal = 0;

        for (List<String> rTuple : sortedRowTuples) {
            matrix.put(rTuple, new HashMap<>());
            rowTotals.put(rTuple, 0);
        }
        for (List<String> cTuple : sortedColTuples) {
            colTotals.put(cTuple, 0);
        }

        boolean isSum = "SUM".equalsIgnoreCase(aggType) && aggField != null && !aggField.trim().isEmpty();

        for (Map<String, String> row : data) {
            List<String> rTuple = new ArrayList<>();
            boolean validRow = true;
            for (String field : rowFields) {
                String val = row.get(field);
                if (val == null || val.trim().isEmpty() || val.trim().equalsIgnoreCase("(blank)") || (val.trim().length() > 50 && val.trim().length() > rowFences.get(field))) {
                    validRow = false;
                    break;
                }
                rTuple.add(val.trim());
            }

            List<String> cTuple = new ArrayList<>();
            boolean validCol = true;
            for (String field : colFields) {
                String val = row.get(field);
                if (val == null || val.trim().isEmpty() || val.trim().equalsIgnoreCase("(blank)") || (val.trim().length() > 50 && val.trim().length() > colFences.get(field))) {
                    validCol = false;
                    break;
                }
                cTuple.add(val.trim());
            }

            if (!validRow || !validCol) {
                continue;
            }

            int increment = 1;
            if (isSum) {
                increment = parseValue(row.get(aggField));
            }

            Map<List<String>, Integer> colMap = matrix.get(rTuple);
            if (colMap != null) {
                int currentVal = colMap.getOrDefault(cTuple, 0);
                colMap.put(cTuple, currentVal + increment);

                rowTotals.put(rTuple, rowTotals.get(rTuple) + increment);
                colTotals.put(cTuple, colTotals.get(cTuple) + increment);
                grandTotal += increment;
            }
        }

        result.setMatrix(matrix);
        result.setRowTotals(rowTotals);
        result.setColTotals(colTotals);
        result.setGrandTotal(grandTotal);

        Map<String, Integer> rowSpans = new HashMap<>();
        for (int f = 0; f < rowFields.size(); f++) {
            for (int r = 0; r < sortedRowTuples.size(); r++) {
                String spanKey = r + "," + f;
                if (rowSpans.containsKey(spanKey)) {
                    continue; 
                }

                int span = 1;
                List<String> currentPrefix = sortedRowTuples.get(r).subList(0, f + 1);
                for (int nextR = r + 1; nextR < sortedRowTuples.size(); nextR++) {
                    List<String> nextPrefix = sortedRowTuples.get(nextR).subList(0, f + 1);
                    if (currentPrefix.equals(nextPrefix)) {
                        span++;
                        rowSpans.put(nextR + "," + f, 0); 
                    } else {
                        break;
                    }
                }
                rowSpans.put(spanKey, span);
            }
        }
        result.setRowSpans(rowSpans);

        Map<String, Integer> colSpans = new HashMap<>();
        for (int l = 0; l < colFields.size(); l++) {
            for (int c = 0; c < sortedColTuples.size(); c++) {
                String spanKey = l + "," + c;
                if (colSpans.containsKey(spanKey)) {
                    continue; 
                }

                int span = 1;
                List<String> currentPrefix = sortedColTuples.get(c).subList(0, l + 1);
                for (int nextC = c + 1; nextC < sortedColTuples.size(); nextC++) {
                    List<String> nextPrefix = sortedColTuples.get(nextC).subList(0, l + 1);
                    if (currentPrefix.equals(nextPrefix)) {
                        span++;
                        colSpans.put(l + "," + nextC, 0); 
                    } else {
                        break;
                    }
                }
                colSpans.put(spanKey, span);
            }
        }
        result.setColSpans(colSpans);

        return result;
    }

    private static void generateCartesian(List<Set<String>> sets, int index, List<String> current, List<List<String>> result) {
        if (index == sets.size()) {
            result.add(new ArrayList<>(current));
            return;
        }
        for (String val : sets.get(index)) {
            current.add(val);
            generateCartesian(sets, index + 1, current, result);
            current.remove(current.size() - 1);
        }
    }

    private static int parseValue(String val) {
        if (val == null || val.trim().isEmpty()) return 0;
        try {
            if (val.contains(".")) {
                return (int) Double.parseDouble(val.trim());
            }
            return Integer.parseInt(val.trim());
        } catch (NumberFormatException e) {
            return 0;
        }
    }
}