package apps.csvpivot.util;

import java.util.*;

public class CsvParserService {
    
    public static class CsvData {
        private List<String> headers;
        private List<Map<String, String>> rows;
        
        public CsvData(List<String> headers, List<Map<String, String>> rows) {
            this.headers = headers;
            this.rows = rows;
        }

        public List<String> getHeaders() {
            return headers;
        }

        public List<Map<String, String>> getRows() {
            return rows;
        }
    }

    public static CsvData parse(String csvContent) throws Exception {
        if (csvContent == null) {
            throw new IllegalArgumentException("CSV content cannot be null");
        }

        List<List<String>> allRecords = new ArrayList<>();
        StringBuilder sb = new StringBuilder();
        boolean inQuotes = false;
        List<String> currentRecord = new ArrayList<>();
        
        for (int i = 0; i < csvContent.length(); i++) {
            char c = csvContent.charAt(i);
            
            if (inQuotes) {
                if (c == '"') {
                    if (i + 1 < csvContent.length() && csvContent.charAt(i + 1) == '"') {
                        sb.append('"');
                        i++; 
                    } else {
                        inQuotes = false;
                    }
                } else {
                    sb.append(c);
                }
            } else {
                if (c == '"') {
                    inQuotes = true;
                } else if (c == ',') {
                    currentRecord.add(sb.toString().trim());
                    sb.setLength(0);
                } else if (c == '\n' || c == '\r') {
                    currentRecord.add(sb.toString().trim());
                    sb.setLength(0);
                    
                    if (!currentRecord.isEmpty() && !(currentRecord.size() == 1 && currentRecord.get(0).isEmpty())) {
                        allRecords.add(new ArrayList<>(currentRecord));
                    }
                    currentRecord.clear();
                    
                    if (c == '\r' && i + 1 < csvContent.length() && csvContent.charAt(i + 1) == '\n') {
                        i++;
                    }
                } else {
                    sb.append(c);
                }
            }
        }
        
        if (sb.length() > 0 || !currentRecord.isEmpty()) {
            currentRecord.add(sb.toString().trim());
            if (!currentRecord.isEmpty() && !(currentRecord.size() == 1 && currentRecord.get(0).isEmpty())) {
                allRecords.add(currentRecord);
            }
        }
        
        if (allRecords.isEmpty()) {
            throw new IllegalArgumentException("CSV file contains no readable data");
        }
        
        List<String> headers = allRecords.get(0);
        // Clean headers (remove BOM or surrounding whitespace if any)
        for (int i = 0; i < headers.size(); i++) {
            String h = headers.get(i);
            if (h.startsWith("\uFEFF")) {
                h = h.substring(1);
            }
            headers.set(i, h.trim());
        }

        List<Map<String, String>> rows = new ArrayList<>();
        
        for (int i = 1; i < allRecords.size(); i++) {
            List<String> record = allRecords.get(i);
            Map<String, String> row = new LinkedHashMap<>();
            for (int h = 0; h < headers.size(); h++) {
                String header = headers.get(h);
                String value = "";
                if (h < record.size()) {
                    value = record.get(h);
                }
                if (value == null) {
                    value = "";
                } else {
                    value = value.trim();
                }
                row.put(header, value);
            }
            rows.add(row);
        }
        
        return new CsvData(headers, rows);
    }
}
