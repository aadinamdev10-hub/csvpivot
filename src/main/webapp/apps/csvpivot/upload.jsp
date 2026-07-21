<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard — CSV Pivot Report</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/apps/csvpivot/css/style.css">
    <style>
        /* ── Page layout ── */
        * {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif !important;
        }

        .page-body {
            background: #f8fafc;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            padding: 0 !important;
            margin: 0;
            align-items: stretch !important;
        }

        /* ── Two-column top section ── */
        .top-grid {
            display: grid;
            grid-template-columns: 1.1fr 0.9fr;
            gap: 1.5rem;
            margin-bottom: 1.75rem;
        }
        @media (max-width: 860px) {
            .top-grid { grid-template-columns: 1fr; }
        }

        /* ── Card ── */
        .card {
            background: #fff;
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.06);
        }
        .card-header {
            padding: 1rem 1.25rem 0.75rem;
            border-bottom: 1px solid #f1f5f9;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .card-title {
            font-family: 'Outfit', sans-serif;
            font-size: 0.95rem;
            font-weight: 700;
            color: #0f172a;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        .card-title-icon {
            width: 26px; height: 26px;
            border-radius: 6px;
            background: #eff6ff;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #1565c0;
        }
        .card-body { padding: 1.1rem 1.25rem 1.25rem; }

        /* ── Upload zone ── */
        .upload-zone-v2 {
            border: 2px dashed #cbd5e1;
            border-radius: 6px;
            padding: 2.25rem 1.5rem;
            text-align: center;
            background: #f8fafc;
            cursor: pointer;
            transition: border-color 0.2s, background 0.2s;
            position: relative;
        }
        .upload-zone-v2:hover { border-color: #1565c0; background: #eff6ff; }
        .upload-zone-v2 input[type="file"] { position:absolute; inset:0; opacity:0; cursor:pointer; }
        .upload-zone-v2 .uz-icon {
            width: 40px; height: 40px;
            border-radius: 8px;
            background: #dbeafe;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 0.75rem;
            color: #1565c0;
        }
        .upload-zone-v2 .uz-label { font-weight:600; font-size:0.9rem; color:#0f172a; margin-bottom:0.2rem; }
        .upload-zone-v2 .uz-sub   { font-size:0.78rem; color:#94a3b8; }

        /* ── Upload button ── */
        .upload-btn {
            display: inline-flex;
            align-items: center;
            gap: 0.4rem;
            margin-top: 1rem;
            width: 100%;
            justify-content: center;
            padding: 0.6rem 1.25rem;
            background: #1565c0;
            color: #fff;
            border: none;
            border-radius: 6px;
            font-family: inherit;
            font-size: 0.875rem;
            font-weight: 600;
            cursor: pointer;
            transition: background 0.15s, transform 0.1s;
        }
        .upload-btn:hover:not(:disabled) { background: #0d47a1; transform: translateY(-1px); }
        .upload-btn:active:not(:disabled) { transform: translateY(0); }
        .upload-btn:disabled { background:#e2e8f0; color:#94a3b8; cursor:not-allowed; }

        /* ── Stats ── */
        .stats-grid { display:grid; grid-template-columns:1fr 1fr; gap:0.85rem; margin-bottom:1rem; }
        .stat-box {
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            border-radius: 6px;
            padding: 0.85rem 1rem;
        }
        .stat-box .stat-num { font-family:'Outfit',sans-serif; font-size:1.6rem; font-weight:700; color:#0f172a; line-height:1; margin-bottom:0.2rem; }
        .stat-box .stat-label { font-size:0.72rem; font-weight:600; color:#64748b; text-transform:uppercase; letter-spacing:0.05em; }
        .tip-box {
            background: #f0fdf4;
            border: 1px solid #bbf7d0;
            border-radius: 6px;
            padding: 0.75rem 0.9rem;
            font-size: 0.78rem;
            color: #166534;
            display: flex;
            align-items: flex-start;
            gap: 0.4rem;
        }

        /* ── Reports table card ── */
        .reports-card {
            background: #fff;
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.06);
            overflow: hidden;
        }
        .reports-card-header {
            padding: 1rem 1.25rem;
            border-bottom: 1px solid #f1f5f9;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .reports-card-title {
            font-family: 'Outfit', sans-serif;
            font-size: 0.95rem;
            font-weight: 700;
            color: #0f172a;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        .count-badge {
            background: #eff6ff;
            color: #1565c0;
            font-size: 0.72rem;
            font-weight: 700;
            padding: 0.15rem 0.5rem;
            border-radius: 20px;
        }

        /* ── Table ── */
        .reports-table { width:100%; border-collapse:collapse; font-size:0.86rem; }
        .reports-table thead tr { background:#f8fafc; border-bottom:2px solid #e2e8f0; }
        .reports-table thead th {
            padding: 0.65rem 1.1rem;
            text-align: left;
            font-size: 0.72rem;
            font-weight: 700;
            color: #64748b;
            text-transform: uppercase;
            letter-spacing: 0.07em;
            white-space: nowrap;
        }
        .reports-table thead th.th-center { text-align:center; }
        .reports-table tbody tr { border-bottom:1px solid #f1f5f9; transition:background 0.1s; }
        .reports-table tbody tr:last-child { border-bottom:none; }
        .reports-table tbody tr:hover { background:#f8fafc; }
        .reports-table tbody td { padding:0.9rem 1.1rem; color:#334155; vertical-align:middle; }
        .reports-table .td-num  { color:#94a3b8; font-size:0.78rem; font-weight:600; width:36px; }
        .reports-table .td-name { font-weight:600; color:#0f172a; }
        .reports-table .td-file span {
            display:inline-flex; align-items:center; gap:0.3rem;
            background:#f1f5f9; border:1px solid #e2e8f0;
            padding:0.18rem 0.55rem; border-radius:4px; font-size:0.78rem;
        }
        .agg-badge {
            display:inline-block;
            background:#eff6ff; color:#1565c0; border:1px solid #bfdbfe;
            padding:0.15rem 0.5rem; border-radius:4px;
            font-size:0.73rem; font-weight:700;
        }
        .agg-badge.sum { background:#fdf4ff; color:#7e22ce; border-color:#e9d5ff; }
        .reports-table .td-date { font-size:0.78rem; color:#64748b; white-space:nowrap; }
        .reports-table .td-actions { text-align:center; white-space:nowrap; }

        /* ── Action buttons ── */
        .btn-view {
            display:inline-flex; align-items:center; gap:0.3rem;
            background:#1565c0; color:#fff; text-decoration:none;
            padding:0.35rem 0.85rem; border-radius:5px;
            font-size:0.77rem; font-weight:600; font-family:inherit;
            border:none; cursor:pointer;
            transition: background 0.14s, transform 0.1s;
            margin-right:0.35rem;
        }
        .btn-view:hover { background:#0d47a1; transform:translateY(-1px); }
        .btn-view:active { transform:translateY(0); }
        .btn-del {
            display:inline-flex; align-items:center; gap:0.3rem;
            background:#fff; color:#dc2626; border:1.5px solid #fca5a5;
            padding:0.33rem 0.8rem; border-radius:5px;
            font-size:0.77rem; font-weight:600; font-family:inherit; cursor:pointer;
            transition: background 0.14s, border-color 0.14s, transform 0.1s;
        }
        .btn-del:hover { background:#fef2f2; border-color:#dc2626; transform:translateY(-1px); }
        .btn-del:active { transform:translateY(0); }

        /* ── Empty state ── */
        .empty-state { padding:3.5rem 2rem; text-align:center; color:#94a3b8; }
        .empty-state svg { display:block; margin:0 auto 1rem; color:#cbd5e1; }
        .empty-state p { font-size:0.875rem; max-width:340px; margin:0 auto; }

        /* ── Alert ── */
        .page-alert {
            background:#fef2f2; border:1px solid #fca5a5; color:#991b1b;
            border-radius:6px; padding:0.75rem 1rem;
            font-size:0.875rem; font-weight:500;
            margin-bottom:1.1rem;
            display:flex; align-items:center; gap:0.5rem;
        }

        /* ── Page wrapper ── */
        .page-wrap {
            flex: 1;
            width: 96%;
            max-width: 100%;
            margin: 0 auto;
            padding: 2rem 0 3rem;
        }

        /* ── Page heading ── */
        .page-heading {
            margin-bottom: 1.75rem;
        }
        .page-heading h1 {
            font-family: 'Outfit', sans-serif;
            font-size: 1.5rem;
            font-weight: 700;
            color: #0f172a;
            margin-bottom: 0.2rem;
        }
        .page-heading p {
            color: #64748b;
            font-size: 0.875rem;
        }

        /* ── Two-column top section ── */
        .top-grid {
            display: grid;
            grid-template-columns: 1.1fr 0.9fr;
            gap: 1.5rem;
            margin-bottom: 1.75rem;
        }
        @media (max-width: 860px) {
            .top-grid { grid-template-columns: 1fr; }
        }

        /* ── Card ── */
        .card {
            background: #fff;
            border: 1px solid #e2e8f0;
            border-radius: 10px;
            box-shadow: 0 1px 4px rgba(0,0,0,0.06);
        }
        .card-header {
            padding: 1.1rem 1.5rem 0.75rem;
            border-bottom: 1px solid #f1f5f9;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .card-title {
            font-family: 'Outfit', sans-serif;
            font-size: 0.95rem;
            font-weight: 700;
            color: #0f172a;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        .card-title-icon {
            width: 28px; height: 28px;
            border-radius: 6px;
            background: #eff6ff;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #2563eb;
        }
        .card-body {
            padding: 1.25rem 1.5rem 1.5rem;
        }

        /* ── Upload zone ── */
        .upload-zone-v2 {
            border: 2px dashed #cbd5e1;
            border-radius: 8px;
            padding: 2.5rem 1.5rem;
            text-align: center;
            background: #f8fafc;
            cursor: pointer;
            transition: border-color 0.2s, background 0.2s;
            position: relative;
        }
        .upload-zone-v2:hover {
            border-color: #2563eb;
            background: #eff6ff;
        }
        .upload-zone-v2 input[type="file"] {
            position: absolute;
            inset: 0;
            opacity: 0;
            cursor: pointer;
        }
        .upload-zone-v2 .uz-icon {
            width: 44px; height: 44px;
            border-radius: 10px;
            background: #dbeafe;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 0.85rem;
            color: #2563eb;
        }
        .upload-zone-v2 .uz-label {
            font-weight: 600;
            font-size: 0.92rem;
            color: #0f172a;
            margin-bottom: 0.2rem;
        }
        .upload-zone-v2 .uz-sub {
            font-size: 0.78rem;
            color: #94a3b8;
        }

        /* ── Upload submit button ── */
        .upload-btn {
            display: inline-flex;
            align-items: center;
            gap: 0.45rem;
            margin-top: 1.1rem;
            width: 100%;
            justify-content: center;
            padding: 0.65rem 1.5rem;
            background: #2563eb;
            color: #fff;
            border: none;
            border-radius: 7px;
            font-family: inherit;
            font-size: 0.875rem;
            font-weight: 600;
            cursor: pointer;
            transition: background 0.15s, box-shadow 0.15s, transform 0.1s;
            box-shadow: 0 2px 8px rgba(37,99,235,0.2);
            letter-spacing: 0.01em;
        }
        .upload-btn:hover:not(:disabled) {
            background: #1d4ed8;
            box-shadow: 0 4px 12px rgba(37,99,235,0.3);
            transform: translateY(-1px);
        }
        .upload-btn:active:not(:disabled) { transform: translateY(0); }
        .upload-btn:disabled {
            background: #e2e8f0;
            color: #94a3b8;
            cursor: not-allowed;
            box-shadow: none;
        }

        /* ── Stats panel ── */
        .stats-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1rem;
            margin-bottom: 1.25rem;
        }
        .stat-box {
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            padding: 1rem 1.1rem;
        }
        .stat-box .stat-num {
            font-family: 'Outfit', sans-serif;
            font-size: 1.75rem;
            font-weight: 700;
            color: #0f172a;
            line-height: 1;
            margin-bottom: 0.2rem;
        }
        .stat-box .stat-label {
            font-size: 0.75rem;
            font-weight: 600;
            color: #64748b;
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }
        .tip-box {
            background: #f0fdf4;
            border: 1px solid #bbf7d0;
            border-radius: 8px;
            padding: 0.85rem 1rem;
            font-size: 0.8rem;
            color: #166534;
            display: flex;
            align-items: flex-start;
            gap: 0.5rem;
        }

        /* ── Reports table card ── */
        .reports-card {
            background: #fff;
            border: 1px solid #e2e8f0;
            border-radius: 10px;
            box-shadow: 0 1px 4px rgba(0,0,0,0.06);
            overflow: hidden;
        }
        .reports-card-header {
            padding: 1.1rem 1.5rem;
            border-bottom: 1px solid #f1f5f9;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .reports-card-title {
            font-family: 'Outfit', sans-serif;
            font-size: 0.95rem;
            font-weight: 700;
            color: #0f172a;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        .count-badge {
            background: #eff6ff;
            color: #2563eb;
            font-size: 0.72rem;
            font-weight: 700;
            padding: 0.15rem 0.55rem;
            border-radius: 20px;
            letter-spacing: 0.03em;
        }

        /* ── Table ── */
        .reports-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 0.86rem;
        }
        .reports-table thead tr {
            background: #f8fafc;
            border-bottom: 2px solid #e2e8f0;
        }
        .reports-table thead th {
            padding: 0.7rem 1.25rem;
            text-align: left;
            font-size: 0.72rem;
            font-weight: 700;
            color: #64748b;
            text-transform: uppercase;
            letter-spacing: 0.07em;
            white-space: nowrap;
        }
        .reports-table thead th.th-center { text-align: center; }
        .reports-table tbody tr {
            border-bottom: 1px solid #f1f5f9;
            transition: background 0.12s;
        }
        .reports-table tbody tr:last-child { border-bottom: none; }
        .reports-table tbody tr:hover { background: #f8fafc; }
        .reports-table tbody td {
            padding: 0.95rem 1.25rem;
            color: #334155;
            vertical-align: middle;
        }
        .reports-table .td-num {
            color: #94a3b8;
            font-size: 0.8rem;
            font-weight: 600;
            width: 40px;
        }
        .reports-table .td-name {
            font-weight: 600;
            color: #0f172a;
        }
        .reports-table .td-file {
            color: #475569;
        }
        .reports-table .td-file span {
            display: inline-flex;
            align-items: center;
            gap: 0.3rem;
            background: #f1f5f9;
            border: 1px solid #e2e8f0;
            padding: 0.2rem 0.6rem;
            border-radius: 4px;
            font-size: 0.8rem;
        }
        .reports-table .td-agg { }
        .agg-badge {
            display: inline-block;
            background: #f0f9ff;
            color: #0369a1;
            border: 1px solid #bae6fd;
            padding: 0.18rem 0.55rem;
            border-radius: 4px;
            font-size: 0.75rem;
            font-weight: 700;
            letter-spacing: 0.03em;
        }
        .agg-badge.sum {
            background: #fdf4ff;
            color: #7e22ce;
            border-color: #e9d5ff;
        }
        .reports-table .td-date {
            font-size: 0.8rem;
            color: #64748b;
            white-space: nowrap;
        }
        .reports-table .td-actions {
            text-align: center;
            white-space: nowrap;
        }

        /* ── Action buttons ── */
        .btn-view {
            display: inline-flex;
            align-items: center;
            gap: 0.3rem;
            background: #2563eb;
            color: #fff;
            text-decoration: none;
            padding: 0.38rem 0.9rem;
            border-radius: 6px;
            font-size: 0.78rem;
            font-weight: 600;
            font-family: inherit;
            letter-spacing: 0.01em;
            border: none;
            cursor: pointer;
            box-shadow: 0 1px 4px rgba(37,99,235,0.2);
            transition: background 0.15s, box-shadow 0.15s, transform 0.1s;
            margin-right: 0.4rem;
        }
        .btn-view:hover {
            background: #1d4ed8;
            box-shadow: 0 3px 10px rgba(37,99,235,0.3);
            transform: translateY(-1px);
        }
        .btn-view:active { transform: translateY(0); }

        .btn-del {
            display: inline-flex;
            align-items: center;
            gap: 0.3rem;
            background: #fff;
            color: #dc2626;
            border: 1.5px solid #fca5a5;
            padding: 0.36rem 0.85rem;
            border-radius: 6px;
            font-size: 0.78rem;
            font-weight: 600;
            font-family: inherit;
            letter-spacing: 0.01em;
            cursor: pointer;
            transition: background 0.15s, border-color 0.15s, box-shadow 0.15s, transform 0.1s;
        }
        .btn-del:hover {
            background: #fef2f2;
            border-color: #dc2626;
            box-shadow: 0 2px 8px rgba(220,38,38,0.12);
            transform: translateY(-1px);
        }
        .btn-del:active { transform: translateY(0); }

        /* ── Empty state ── */
        .empty-state {
            padding: 4rem 2rem;
            text-align: center;
            color: #94a3b8;
        }
        .empty-state svg {
            display: block;
            margin: 0 auto 1rem;
            color: #cbd5e1;
        }
        .empty-state p {
            font-size: 0.875rem;
            max-width: 340px;
            margin: 0 auto;
        }

        /* ── Alert ── */
        .page-alert {
            background: #fef2f2;
            border: 1px solid #fca5a5;
            color: #991b1b;
            border-radius: 8px;
            padding: 0.85rem 1.1rem;
            font-size: 0.875rem;
            font-weight: 500;
            margin-bottom: 1.25rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        /* ── Footer ── */
        .site-footer {
            background: #0f172a;
            color: #475569;
            text-align: center;
            padding: 1.25rem 1rem;
            font-size: 0.78rem;
            border-top: 3px solid #1e3a5f;
        }
        .site-footer strong { color: #94a3b8; }
    </style>
</head>
<body class="page-body">

    <!-- Full App Institutional Header -->
    <header style="background:#fff; border-bottom:3px solid #1e3a5f;">

        <!-- App Banner -->
        <div style="padding:0.5rem 2rem; display:flex; align-items:center; justify-content:center; flex-wrap:wrap; gap:1rem; background:#fff;">
            <img src="${pageContext.request.contextPath}/apps/csvpivot/images/App_banner.png"
                 alt="App Portal Banner"
                 style="height:auto; max-height:120px; width:auto; max-width:100%; object-fit:contain; display:block; margin:0 auto;">
        </div>
        <!-- Dark Navy Navbar -->
        <nav style="background:#0f294a; color:#fff; padding:0 2rem; display:flex; justify-content:space-between; align-items:center; box-shadow:0 2px 4px rgba(0,0,0,0.15); min-height:44px;">
            <span style="font-family:'Outfit',sans-serif; font-weight:700; font-size:0.95rem; display:flex; align-items:center; gap:0.5rem;">
                CSV PIVOT <span style="background:#f59e0b; color:#000; font-size:0.66rem; font-weight:700; padding:0.1rem 0.4rem; border-radius:3px;">ADMIN</span>
            </span>
            <a href="${pageContext.request.contextPath}/apps/csvpivot/upload" style="color:#94a3b8; text-decoration:none; font-size:0.82rem; font-weight:500;"
               onmouseover="this.style.color='#fff'" onmouseout="this.style.color='#94a3b8'">Dashboard</a>
        </nav>
    </header>

    <!-- Main -->
    <div class="page-wrap">

        <!-- Page heading -->
        <div class="page-heading">
            <h1>Pivot Report Dashboard</h1>
            <p>Upload a CSV dataset, configure the pivot dimensions, and generate tabular reports.</p>
        </div>

        <!-- Alert -->
        <c:if test="${not empty error}">
            <div class="page-alert">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                ${error}
            </div>
        </c:if>

        <!-- Top 2-col section -->
        <div class="top-grid">

            <!-- Upload Card -->
            <div class="card">
                <div class="card-header">
                    <div class="card-title">
                        <div class="card-title-icon">
                            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
                        </div>
                        Upload Dataset
                    </div>
                </div>
                <div class="card-body">
                    <form action="${pageContext.request.contextPath}/apps/csvpivot/upload" method="POST" enctype="multipart/form-data" id="uploadForm">
                        <div class="upload-zone-v2" id="uploadZone">
                            <div class="uz-icon">
                                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
                            </div>
                            <div class="uz-label" id="uploadText">Click or Drag &amp; Drop CSV here</div>
                            <div class="uz-sub">Supports standard CSV files up to 10 MB</div>
                            <input type="file" name="csvFile" id="csvFileInput" accept=".csv" required>
                        </div>
                        <button type="submit" class="upload-btn" id="submitBtn" disabled>
                            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
                            Upload &amp; Configure
                        </button>
                    </form>
                </div>
            </div>

            <!-- Stats Card -->
            <div class="card">
                <div class="card-header">
                    <div class="card-title">
                        <div class="card-title-icon">
                            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2"/><path d="M3 9h18M9 21V9"/></svg>
                        </div>
                        Overview
                    </div>
                </div>
                <div class="card-body">
                    <div class="stats-grid">
                        <div class="stat-box">
                            <div class="stat-num">${savedConfigs.size()}</div>
                            <div class="stat-label">Total Reports</div>
                        </div>
                        <div class="stat-box">
                            <div class="stat-num">
                                <c:set var="sumCount" value="0"/>
                                <c:forEach var="cfg" items="${savedConfigs}">
                                    <c:if test="${cfg.aggType == 'SUM'}">
                                        <c:set var="sumCount" value="${sumCount + 1}"/>
                                    </c:if>
                                </c:forEach>
                                ${sumCount}
                            </div>
                            <div class="stat-label">SUM Reports</div>
                        </div>
                        <div class="stat-box">
                            <div class="stat-num">${savedConfigs.size() - sumCount}</div>
                            <div class="stat-label">COUNT Reports</div>
                        </div>
                        <div class="stat-box">
                            <c:set var="uniqueFiles" value="0"/>
                            <c:set var="seenFiles" value=""/>
                            <c:forEach var="cfg" items="${savedConfigs}">
                                <c:if test="${not fn:contains(seenFiles, cfg.datasetFilename)}">
                                    <c:set var="uniqueFiles" value="${uniqueFiles + 1}"/>
                                    <c:set var="seenFiles" value="${seenFiles},${cfg.datasetFilename}"/>
                                </c:if>
                            </c:forEach>
                            <div class="stat-num">${uniqueFiles}</div>
                            <div class="stat-label">Datasets</div>
                        </div>
                    </div>
                    <div class="tip-box">
                        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" style="flex-shrink:0;margin-top:1px;"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                        Upload a CSV, choose row &amp; column fields, then generate your pivot table. Share the read-only link with viewers.
                    </div>
                </div>
            </div>
        </div>

        <!-- Reports Table -->
        <div class="reports-card">
            <div class="reports-card-header">
                <div class="reports-card-title">
                    <svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#2563eb" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>
                    Saved Pivot Reports
                    <span class="count-badge">${savedConfigs.size()} total</span>
                </div>
            </div>

            <c:choose>
                <c:when test="${empty savedConfigs}">
                    <div class="empty-state">
                        <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.25" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg>
                        <p>No saved reports yet. Upload a CSV file above and configure it to get started.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div style="overflow-x: auto;">
                        <table class="reports-table">
                            <thead>
                                <tr>
                                    <th>#</th>
                                    <th>Report Name</th>
                                    <th>Dataset File</th>
                                    <th>Aggregation</th>
                                    <th>Created At</th>
                                    <th class="th-center">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="cfg" items="${savedConfigs}" varStatus="loop">
                                    <tr>
                                        <td class="td-num">${loop.index + 1}</td>
                                        <td class="td-name">${cfg.name}</td>
                                        <td class="td-file">
                                            <span>
                                                <svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                                                ${cfg.datasetFilename}
                                            </span>
                                        </td>
                                        <td class="td-agg">
                                            <c:choose>
                                                <c:when test="${cfg.aggType == 'SUM'}">
                                                    <span class="agg-badge sum">SUM &middot; ${cfg.aggField}</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="agg-badge">COUNT</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="td-date">${cfg.createdAt}</td>
                                        <td class="td-actions">
                                            <a href="${pageContext.request.contextPath}/apps/csvpivot/report?configId=${cfg.id}" class="btn-view">
                                                <svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                                                View
                                            </a>
                                            <button class="btn-del" onclick="confirmDelete(${cfg.id}, '${cfg.name}')">
                                                <svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6"/><path d="M10 11v6M14 11v6M9 6V4h6v2"/></svg>
                                                Delete
                                            </button>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

    </div><!-- /page-wrap -->

    <!-- Footer -->
    <footer class="site-footer">
        <p>&copy; 2026 <strong>Application Portal, Main Campus</strong>. All Rights Reserved.</p>
    </footer>

    <script>
        const fileInput  = document.getElementById('csvFileInput');
        const uploadZone = document.getElementById('uploadZone');
        const uploadText = document.getElementById('uploadText');
        const submitBtn  = document.getElementById('submitBtn');

        fileInput.addEventListener('change', (e) => {
            const files = e.target.files;
            if (files && files.length > 0) {
                const file = files[0];
                if (file.name.toLowerCase().endsWith('.csv')) {
                    uploadText.innerHTML = 'Selected: <strong>' + file.name + '</strong> (' + (file.size / 1024).toFixed(1) + ' KB)';
                    uploadZone.style.borderColor = '#2563eb';
                    uploadZone.style.background  = '#eff6ff';
                    submitBtn.disabled = false;
                } else {
                    uploadText.innerHTML = '<span style="color:#dc2626">Invalid file type. Please select a CSV file.</span>';
                    uploadZone.style.borderColor = '#fca5a5';
                    uploadZone.style.background  = '#fef2f2';
                    submitBtn.disabled = true;
                    fileInput.value = '';
                }
            }
        });

        ['dragenter', 'dragover'].forEach(ev => {
            uploadZone.addEventListener(ev, (e) => {
                e.preventDefault();
                uploadZone.style.borderColor = '#2563eb';
                uploadZone.style.background  = '#eff6ff';
            }, false);
        });

        uploadZone.addEventListener('dragleave', () => {
            if (fileInput.files.length === 0) {
                uploadZone.style.borderColor = '#cbd5e1';
                uploadZone.style.background  = '#f8fafc';
            }
        });

        uploadZone.addEventListener('drop', (e) => {
            e.preventDefault();
            const files = e.dataTransfer.files;
            if (files && files.length > 0) {
                fileInput.files = files;
                fileInput.dispatchEvent(new Event('change'));
            }
        });

        function confirmDelete(configId, reportName) {
            if (confirm('Delete report:\n"' + reportName + '"\n\nThis action cannot be undone.')) {
                window.location.href = '${pageContext.request.contextPath}/apps/csvpivot/settings/delete?configId=' + configId;
            }
        }
    </script>
</body>
</html>