<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
    if (request.getAttribute("pivotResult") == null || request.getAttribute("config") == null) {
        response.sendRedirect(request.getContextPath() + "/apps/csvpivot/upload");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Report — ${config.name} | App Portal</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/apps/csvpivot/css/style.css">
    <style>
        /* ── Page design matching Admall portal ── */
        :root {
            --primary:        #0d2d77;      /* Premium deep blue */
            --primary-dk:     #081d4f;      /* Deeper navy hover */
            --primary-light:  #f0f4ff;      /* Light blue bg */
            --accent:         #ffcc00;      /* Warm golden accent */
            --bg:             #f8fafc;      /* Light gray background */
            --border:         #e2e8f0;      /* Slate border */
            --text:           #0f172a;      /* Text slate */
            --muted:          #64748b;      /* Muted slate */
            --radius:         10px;
        }

        * {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif !important;
        }

        .page-body {
            background: var(--bg);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            color: var(--text);
            margin: 0;
            padding: 0 !important;
            align-items: stretch !important;
        }

        /* ── App Banner (matches Admall) ── */
        .App-banner {
            background: #fff;
            padding: 0.75rem 1.5rem;
            display: flex;
            justify-content: center;
            align-items: center;
            border-bottom: 4px solid var(--primary);
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
            width: 100%;
            box-sizing: border-box;
        }
        .App-logo-img {
            max-height: 120px;
            width: auto;
            max-width: 100%;
            display: block;
            object-fit: contain;
        }

        /* ── Navigation Tabs Bar (matches Admall) ── */
        .tabs-nav {
            background: var(--primary);
            display: flex;
            padding: 0 2rem;
            gap: 1.5rem;
            border-bottom: 1px solid rgba(255,255,255,0.1);
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
            min-height: 48px;
            align-items: center;
            box-sizing: border-box;
        }
        .tabs-nav a {
            color: rgba(255,255,255,0.75);
            text-decoration: none;
            padding: 0.8rem 0.5rem;
            font-size: 0.9rem;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            border-bottom: 3px solid transparent;
            transition: all 0.25s ease;
        }
        .tabs-nav a:hover {
            color: #fff;
        }
        .tabs-nav a.active {
            color: #fff;
            border-bottom-color: var(--accent);
        }
        .user-menu-top {
            margin-left: auto;
            display: flex;
            align-items: center;
            gap: 1rem;
            align-self: center;
        }
        .user-menu-name {
            font-weight: 600;
            font-size: 0.85rem;
            color: rgba(255, 255, 255, 0.9);
        }

        /* ── Page Layout ── */
        .page {
            padding: 2.5rem;
            width: 100%;
            box-sizing: border-box;
            flex: 1;
        }

        .card {
            background: #fff;
            border: 1px solid var(--border);
            border-radius: var(--radius);
            box-shadow: 0 4px 6px -1px rgba(15, 23, 42, 0.05);
            padding: 1.75rem 2rem;
        }

        /* ── Title block ── */
        .title-block {
            display: flex;
            align-items: center;
            gap: 1.25rem;
            margin-bottom: 1.5rem;
            border-bottom: 2px solid var(--primary);
            padding-bottom: 0.85rem;
            flex-wrap: wrap;
        }
        .title-block h1 {
            font-family: 'Outfit', sans-serif;
            font-size: 1.35rem;
            font-weight: 700;
            color: var(--primary);
            margin: 0;
        }

        /* ── Back button ── */
        .btn-back {
            display: inline-flex;
            align-items: center;
            gap: 0.4rem;
            padding: 0.45rem 1.1rem;
            font-size: 0.82rem;
            font-weight: 600;
            color: var(--primary);
            background: #fff;
            border: 1.5px solid var(--primary);
            border-radius: 6px;
            text-decoration: none;
            transition: all 0.15s ease;
        }
        .btn-back:hover {
            background: var(--primary-light);
        }

        /* ── Toolbar buttons ── */
        .toolbar {
            display: flex;
            justify-content: flex-end;
            gap: 0.75rem;
            margin-bottom: 1.25rem;
            flex-wrap: wrap;
        }
        .btn-action {
            display: inline-flex;
            align-items: center;
            gap: 0.4rem;
            padding: 0.5rem 1.2rem;
            border-radius: 6px;
            font-size: 0.82rem;
            font-weight: 600;
            font-family: inherit;
            cursor: pointer;
            text-decoration: none;
            transition: background 0.15s, transform 0.1s;
        }
        .btn-pdf { background: #dc2626; color: #fff; border: none; }
        .btn-pdf:hover { background: #b91c1c; }
        .btn-excel { background: #16a34a; color: #fff; border: none; }
        .btn-excel:hover { background: #15803d; }
        .btn-settings { background: #fff; color: var(--text); border: 1.5px solid #cbd5e1; }
        .btn-settings:hover { border-color: #94a3b8; background: #f8fafc; }

        /* ── Pivot Table Styles (Clean Light Blue) ── */
        .table-wrap {
            overflow-x: auto;
            margin-top: 1rem;
            border: 1px solid var(--border);
            border-radius: 6px;
        }
        table.pivot-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 0.85rem;
            color: var(--text);
        }
        table.pivot-table th {
            background: #bae6fd !important;
            color: #0369a1 !important;
            padding: 0.75rem 1rem;
            font-weight: 800 !important;
            font-size: 0.82rem;
            border: 1px solid #38bdf8 !important;
            white-space: nowrap;
        }
        table.pivot-table th.corner {
            background: #7dd3fc !important;
            font-weight: 800 !important;
            color: #0369a1 !important;
            text-align: left;
            border: 1px solid #38bdf8 !important;
        }
        table.pivot-table td {
            padding: 0.7rem 1rem;
            border: 1px solid var(--border);
            color: var(--text);
        }
        table.pivot-table td.row-header {
            background: #f8fafc;
            font-weight: 700 !important;
            color: var(--primary);
            border-right: 1.5px solid var(--border);
        }
        table.pivot-table td.row-header-last {
            border-right: 3px solid #7dd3fc !important;
        }
        table.pivot-table td.data-cell {
            text-align: right;
            font-variant-numeric: tabular-nums;
            font-weight: 800 !important;
            background: #fff !important;
            color: #0f172a !important;
        }
        table.pivot-table td.data-cell.zero {
            color: #0f172a !important;
            font-weight: 800 !important;
        }
        table.pivot-table tr:hover td.data-cell {
            background: #f0f9ff !important;
        }
        table.pivot-table td.total, table.pivot-table th.total {
            background: #e0f2fe !important;
            color: #0369a1 !important;
            font-weight: 800 !important;
            text-align: right;
            border-color: #bae6fd !important;
        }
        table.pivot-table td.grand-total {
            background: #bae6fd !important;
            color: #0369a1 !important;
            font-weight: 800 !important;
            text-align: right;
            border-color: #7dd3fc !important;
        }

        /* ── Adjust Settings Modal ── */
        .modal {
            display: none;
            position: fixed;
            z-index: 2000;
            inset: 0;
            background: rgba(15, 23, 42, 0.6);
            backdrop-filter: blur(4px);
        }
        .modal-content {
            background: #fff;
            margin: 6% auto;
            padding: 2rem;
            border: 1px solid var(--border);
            width: 90%;
            max-width: 640px;
            border-radius: var(--radius);
            box-shadow: 0 20px 50px rgba(0,0,0,0.12);
            position: relative;
            animation: modalFadeIn 0.25s ease-out;
        }
        @keyframes modalFadeIn {
            from { opacity: 0; transform: translateY(-16px); }
            to   { opacity: 1; transform: translateY(0); }
        }
        .modal-close {
            position: absolute; right: 1.25rem; top: 0.9rem;
            font-size: 1.5rem; color: var(--muted); cursor: pointer;
            line-height: 1; background: none; border: none; padding: 0;
        }
        .modal h2 {
            font-size: 1.15rem; font-weight: 700; color: var(--primary);
            margin-bottom: 1.25rem;
            padding-bottom: 0.75rem;
            border-bottom: 1px solid var(--border);
        }
        .modal h3 {
            font-size: 0.8rem; font-weight: 700; color: var(--muted);
            text-transform: uppercase; letter-spacing: 0.06em;
            margin-bottom: 0.6rem;
        }
        .config-layout { display: grid; grid-template-columns: 1fr 1fr; gap: 1.25rem; margin-bottom: 1.25rem; }
        @media(max-width:580px){ .config-layout { grid-template-columns: 1fr; } }

        .form-group { margin-bottom: 1rem; }
        .form-group label {
            display: block; font-size: 0.8rem; font-weight: 600;
            color: var(--muted); margin-bottom: 0.35rem;
        }
        .form-control {
            width: 100%; padding: 0.55rem 0.75rem;
            border: 1.5px solid var(--border); border-radius: 6px;
            font-family: inherit; font-size: 0.875rem; color: var(--text);
            background: #fff; transition: border-color 0.15s;
            box-sizing: border-box;
        }
        .form-control:focus {
            outline: none; border-color: var(--primary);
        }
        .level-item { 
            display: flex; 
            align-items: center; 
            gap: 0.6rem; 
            margin-bottom: 0.6rem; 
            background: #f8fafc !important; 
            padding: 0.55rem 0.75rem !important; 
            border-radius: 8px !important; 
            border: 1px solid #e2e8f0 !important; 
            box-shadow: 0 1px 2px rgba(0,0,0,0.02) !important;
            animation: slideIn 0.2s ease-out;
        }
        .level-badge {
            width: 22px !important; 
            height: 22px !important; 
            min-width: 22px !important; 
            border-radius: 50% !important;
            background: #eff6ff !important; 
            color: #1d4ed8 !important;
            border: 1.5px solid #bfdbfe !important;
            font-size: 0.75rem !important; 
            font-weight: 700 !important;
            display: inline-flex; 
            align-items: center; 
            justify-content: center;
        }
        .level-item select {
            flex-grow: 1;
            border: 1.5px solid #cbd5e1 !important;
            border-radius: 6px !important;
            padding: 0.4rem 0.5rem !important;
            background: #fff !important;
            font-size: 0.85rem !important;
            color: #334155 !important;
            font-weight: 500 !important;
            outline: none !important;
            cursor: pointer;
            transition: all 0.15s ease;
        }
        .level-item select:focus {
            border-color: #3b82f6 !important;
            box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1) !important;
        }
        .btn-add-level {
            display: inline-flex; 
            align-items: center; 
            gap: 0.35rem;
            background: #fff !important; 
            color: #2563eb !important; 
            border: 1.5px solid #bfdbfe !important;
            padding: 0.45rem 0.85rem !important; 
            border-radius: 6px !important;
            font-size: 0.8rem !important; 
            font-weight: 600 !important; 
            cursor: pointer;
            transition: all 0.15s ease !important;
        }
        .btn-add-level:hover {
            background: #eff6ff !important;
            border-color: #3b82f6 !important;
            color: #1d4ed8 !important;
        }
        .btn-remove {
            display: inline-flex; 
            align-items: center;
            background: #fff !important; 
            color: #ef4444 !important; 
            border: 1.5px solid #fee2e2 !important;
            padding: 0.4rem 0.75rem !important; 
            border-radius: 6px !important;
            font-size: 0.78rem !important; 
            font-weight: 600 !important; 
            cursor: pointer;
            transition: all 0.15s ease !important;
        }
        .btn-remove:hover {
            background: #fef2f2 !important;
            border-color: #fca5a5 !important;
            color: #b91c1c !important;
        }
        .modal-actions {
            display: flex; 
            justify-content: flex-end; 
            gap: 0.75rem;
            margin-top: 1.75rem; 
            padding-top: 1.25rem;
            border-top: 1px solid var(--border);
        }
        .btn-cancel {
            padding: 0.55rem 1.25rem; 
            border-radius: 6px;
            background: #fff; 
            color: #64748b; 
            border: 1.5px solid var(--border);
            font-size: 0.875rem; 
            font-weight: 600; 
            cursor: pointer;
            transition: all 0.15s ease;
        }
        .btn-cancel:hover {
            background: #f8fafc;
            color: #334155;
            border-color: #cbd5e1;
        }
        .btn-save {
            padding: 0.55rem 1.35rem; 
            border-radius: 6px;
            background: #0f294a !important; 
            color: #fff; 
            border: none;
            font-size: 0.875rem; 
            font-weight: 600; 
            cursor: pointer;
            transition: all 0.15s ease;
        }
        .btn-save:hover {
            background: #1e40af !important;
        }

        /* ── Site Footer ── */
        .site-footer {
            background: #0f172a;
            color: #475569;
            text-align: center;
            padding: 1.25rem 1rem;
            font-size: 0.78rem;
            border-top: 3px solid var(--primary);
        }
        .site-footer strong { color: #94a3b8; }

        /* ── Print layout configurations to fit exactly on ONE single page ── */
        @media print {
            .tabs-nav, .toolbar, .modal, .site-footer, .btn-back {
                display: none !important;
            }

            body, .page-body, .page, .card, .table-wrap {
                background: #fff !important;
                box-shadow: none !important;
                border: none !important;
                padding: 0 !important;
                margin: 0 !important;
                width: 100% !important;
                max-width: 100% !important;
                overflow: visible !important;
            }

            /* Dynamic zoom is handled by JavaScript on beforeprint */

            /* Show simple clean print title header */
            .print-header {
                display: block !important;
                padding-bottom: 0.5rem;
                margin-bottom: 1rem;
                border-bottom: 2px solid #0d2d77;
            }

            /* Adjust table size & padding to fit within a single page */
            table.pivot-table {
                width: 100% !important;
                font-size: 7.5pt !important;
                line-height: 1.2 !important;
                table-layout: auto !important;
            }
            table.pivot-table th, table.pivot-table td {
                padding: 3px 5px !important;
                border: 1px solid #94a3b8 !important;
                word-break: break-word !important;
            }

            @page {
                margin: 5mm;
            }
            
            tr {
                page-break-inside: avoid !important;
                break-inside: avoid !important;
            }
            
            /* Hide empty rows/columns strictly on print */
            tr.zero-row {
                display: none !important;
            }
        }
    </style>
</head>
<body class="page-body">

    <!-- Bilingual App Banner -->
    <div class="App-banner">
        <img src="${pageContext.request.contextPath}/apps/csvpivot/images/App_banner.png" class="App-logo-img" alt="App Portal Logo">
    </div>

    <!-- Navigation Tabs Bar -->
    <div class="tabs-nav no-print">
        <a href="${pageContext.request.contextPath}/apps/csvpivot/upload">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="9"/><rect x="14" y="3" width="7" height="5"/><rect x="14" y="12" width="7" height="9"/><rect x="3" y="16" width="7" height="5"/></svg>
            Datasets Dashboard
        </a>
        <a href="#" class="active">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
            Report
        </a>
        <div class="user-menu-top">
            <span class="user-menu-name">Administrator (SUPERADMIN)</span>
            <a href="${pageContext.request.contextPath}/apps/csvpivot/upload" style="color: white; border: 1px solid rgba(255, 255, 255, 0.4); background: transparent; padding: 0.35rem 0.85rem; border-radius: 4px; font-size: 0.8rem; font-weight: 600; text-decoration: none; transition: all 0.2s;" onmouseover="this.style.background='rgba(255,255,255,0.15)'" onmouseout="this.style.background='transparent'">Logout</a>
        </div>
    </div>

    <!-- Hidden Print Title -->
    <div class="print-header" style="display:none; font-family:'Outfit',sans-serif;">
        <div style="font-size: 14pt; font-weight: 700; color: #0d2d77; margin-bottom: 0.25rem;">App Portal</div>
        <div style="font-size: 10pt; font-weight: 600; color: #334155;">Report: ${config.name}</div>
        <c:if test="${not empty filename}">
            <div style="font-size: 8pt; color: #64748b;">Source Dataset: ${filename}</div>
        </c:if>
    </div>

    <!-- Page Container -->
    <div class="page">
        <div class="card">
            
            <!-- Title Block -->
            <div class="title-block">
                <a href="${pageContext.request.contextPath}/apps/csvpivot/upload" class="btn-back">
                    &larr; Back to Dashboard
                </a>
                <h1>${config.name}</h1>
                <c:if test="${not empty filename}">
                    <span style="margin-left: auto; display: inline-flex; align-items: center; gap: 0.35rem; background: #f0f4ff; border: 1px solid #bfdbfe; color: #0d2d77; padding: 0.35rem 0.85rem; border-radius: 20px; font-size: 0.78rem; font-weight: 600;">
                        Dataset: <strong>${filename}</strong>
                    </span>
                </c:if>
            </div>

            <!-- Toolbar buttons -->
            <div class="toolbar no-print">
                <button onclick="window.print()" class="btn-action btn-pdf">
                    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 6 2 18 2 18 9"/><path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"/><rect x="6" y="14" width="12" height="8"/></svg>
                    Print Report
                </button>
                <a href="${pageContext.request.contextPath}/apps/csvpivot/report?configId=${config.id}&export=excel" class="btn-action btn-excel">
                    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg>
                    Download Excel
                </a>
                <a href="${pageContext.request.contextPath}/apps/csvpivot/report?configId=${config.id}&export=csv" class="btn-action btn-excel" style="background: #0284c7; border-color: #0284c7;">
                    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg>
                    Download CSV
                </a>
                <button onclick="openModal()" class="btn-action btn-settings">
                    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg>
                    Adjust Settings
                </button>
            </div>

            <!-- Table content -->
            <div class="table-wrap">
                <table class="pivot-table">
                    <thead>
                        <!-- Column Headers (Level-by-Level Nesting) -->
                        <c:forEach var="l" begin="0" end="${pivotResult.colFields.size() - 1}">
                            <tr>
                                <!-- Top-Left Corner Empty Header Cells, plus default S.No. column -->
                                <c:if test="${l == 0}">
                                    <th rowspan="${pivotResult.colFields.size()}" class="corner" style="width: 60px; text-align: center;">S.No.</th>
                                    <c:forEach var="rf" items="${pivotResult.rowFields}">
                                        <th rowspan="${pivotResult.colFields.size()}" class="corner">
                                            <strong>${rf}</strong>
                                        </th>
                                    </c:forEach>
                                </c:if>

                                <!-- Column labels for level l -->
                                <c:forEach var="c" begin="0" end="${pivotResult.colTuples.size() - 1}">
                                    <c:set var="colTuple" value="${pivotResult.colTuples[c]}" />
                                    <c:set var="val" value="${colTuple[l]}" />
                                    <c:set var="spanKey" value="${l},${c}" />
                                    <c:set var="span" value="${pivotResult.colSpans[spanKey]}" />
                                    <c:if test="${span > 0}">
                                        <th colspan="${span}" style="text-align: center;">${val}</th>
                                    </c:if>
                                </c:forEach>

                                <!-- Grand Total header cell on the right -->
                                <c:if test="${l == 0}">
                                    <th rowspan="${pivotResult.colFields.size()}" class="total" style="vertical-align: bottom; text-align: right;">Grand Total</th>
                                </c:if>
                            </tr>
                        </c:forEach>
                    </thead>
                    <tbody>
                        <!-- Rows & Cell Matrix -->
                        <c:forEach var="r" begin="0" end="${pivotResult.rowTuples.size() - 1}">
                            <tr>
                                <!-- Sequential Row Number (S.No) -->
                                <td class="row-header" style="text-align: center; width: 60px; font-weight: 700; color: #64748b;">${r + 1}</td>

                                <!-- Row Level grouping headers -->
                                <c:forEach var="f" begin="0" end="${pivotResult.rowFields.size() - 1}">
                                    <c:set var="rowTuple" value="${pivotResult.rowTuples[r]}" />
                                    <c:set var="val" value="${rowTuple[f]}" />
                                    <c:set var="spanKey" value="${r},${f}" />
                                    <c:set var="span" value="${pivotResult.rowSpans[spanKey]}" />
                                    <c:if test="${span > 0}">
                                        <td rowspan="${span}" class="row-header <c:if test='${f == pivotResult.rowFields.size() - 1}'>row-header-last</c:if>">${val}</td>
                                    </c:if>
                                </c:forEach>

                                <!-- Value cells -->
                                <c:forEach var="c" begin="0" end="${pivotResult.colTuples.size() - 1}">
                                    <c:set var="rowTuple" value="${pivotResult.rowTuples[r]}" />
                                    <c:set var="colTuple" value="${pivotResult.colTuples[c]}" />
                                    <c:set var="val" value="${pivotResult.getValue(rowTuple, colTuple)}" />
                                    <td class="data-cell <c:if test='${val == 0}'>zero</c:if>">${val}</td>
                                </c:forEach>

                                <!-- Row totals -->
                                <c:set var="rowTuple" value="${pivotResult.rowTuples[r]}" />
                                <td class="total">${pivotResult.getRowTotal(rowTuple)}</td>
                            </tr>
                        </c:forEach>

                        <!-- Grand Total Bottom Row -->
                        <tr>
                            <!-- Account for the extra S.No column by adding 1 to rowFields.size() -->
                            <td colspan="${pivotResult.rowFields.size() + 1}" class="total" style="text-align: left; border-right: 2px solid #bfdbfe;">Grand Total</td>
                            <c:forEach var="c" begin="0" end="${pivotResult.colTuples.size() - 1}">
                                <c:set var="colTuple" value="${pivotResult.colTuples[c]}" />
                                <td class="total">${pivotResult.getColTotal(colTuple)}</td>
                            </c:forEach>
                            <td class="grand-total">${pivotResult.grandTotal}</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Footer -->
    <footer class="site-footer no-print">
        <p>&copy; 2026 <strong>Application Portal, Main Campus</strong>. All Rights Reserved.</p>
    </footer>

    <!-- Adjust Settings Modal -->
    <div id="settingsModal" class="modal">
        <div class="modal-content">
            <button class="modal-close" onclick="closeModal()">&times;</button>
            <h2>Adjust Report Configuration</h2>
            <form action="${pageContext.request.contextPath}/settings/save" method="POST" id="configForm">
                <input type="hidden" name="configId" value="${config.id}">
                <input type="hidden" name="datasetId" value="${config.datasetId}">
                <div class="form-group">
                    <label for="configName">Report Name</label>
                    <input type="text" name="configName" id="configName" class="form-control"
                           value="${config.name}" placeholder="Enter a report name" required>
                </div>
                <!-- Aggregation Function Selection -->
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1.25rem; margin-bottom: 1.25rem;">
                    <div class="form-group" style="margin-bottom: 0;">
                        <label for="aggType">Aggregation Function *</label>
                        <select name="aggType" id="aggType" class="form-control" onchange="toggleAggField(this.value)">
                            <option value="COUNT" ${config.aggType == 'COUNT' ? 'selected' : ''}>COUNT (Total Records Count)</option>
                            <option value="SUM" ${config.aggType == 'SUM' ? 'selected' : ''}>SUM (Sum of Column Values)</option>
                        </select>
                    </div>
                    <div class="form-group" id="aggFieldGroup" style="margin-bottom: 0; display: ${config.aggType == 'SUM' ? 'block' : 'none'};">
                        <label for="aggField">Select Column to Sum *</label>
                        <select name="aggField" id="aggField" class="form-control" ${config.aggType == 'SUM' ? 'required' : ''}>
                            <c:forEach var="h" items="${headers}">
                                <option value="${h}" ${config.aggField == h ? 'selected' : ''}>${h}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>
                <div class="config-layout">
                    <div>
                        <h3>Row Levels</h3>
                        <div id="rowLevelsContainer"></div>
                        <button type="button" class="btn-add-level" onclick="addRowLevel()">+ Add Level</button>
                    </div>
                    <div>
                        <h3>Column Levels</h3>
                        <div id="colLevelsContainer"></div>
                        <button type="button" class="btn-add-level" onclick="addColLevel()">+ Add Level</button>
                    </div>
                </div>
                <div class="modal-actions">
                    <button type="button" class="btn-cancel" onclick="closeModal()">Cancel</button>
                    <button type="submit" class="btn-save">Save Changes</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        const availableHeaders = [
            <c:forEach items="${headers}" var="h" varStatus="status">
                "${h}"<c:if test="${!status.last}">,</c:if>
            </c:forEach>
        ];
        const initialRowFields = [
            <c:forEach items="${config.rowFields}" var="f" varStatus="status">
                "${f}"<c:if test="${!status.last}">,</c:if>
            </c:forEach>
        ];
        const initialColFields = [
            <c:forEach items="${config.colFields}" var="f" varStatus="status">
                "${f}"<c:if test="${!status.last}">,</c:if>
            </c:forEach>
        ];

        const rowContainer = document.getElementById('rowLevelsContainer');
        const colContainer = document.getElementById('colLevelsContainer');

        function createSelectElement(name, selectedValue = '') {
            const wrapper = document.createElement('div');
            wrapper.className = 'level-item';

            const badge = document.createElement('span');
            badge.className = 'level-badge';
            wrapper.appendChild(badge);

            const select = document.createElement('select');
            select.name = name;
            select.className = 'form-control';
            select.style.flex = '1';
            select.required = true;

            const defOpt = document.createElement('option');
            defOpt.value = '';
            defOpt.textContent = '-- Select Field --';
            select.appendChild(defOpt);

            availableHeaders.forEach(header => {
                const opt = document.createElement('option');
                opt.value = header;
                opt.textContent = header;
                if (header === selectedValue) opt.selected = true;
                select.appendChild(opt);
            });
            wrapper.appendChild(select);

            const deleteBtn = document.createElement('button');
            deleteBtn.type = 'button';
            deleteBtn.className = 'btn-remove';
            deleteBtn.textContent = 'Remove';
            deleteBtn.onclick = () => {
                const container = wrapper.parentElement;
                wrapper.remove();
                rebuildBadges(container.id);
            };
            wrapper.appendChild(deleteBtn);
            return wrapper;
        }

        function rebuildBadges(containerId) {
            const container = document.getElementById(containerId);
            const items = container.getElementsByClassName('level-item');
            for (let i = 0; i < items.length; i++) {
                const badge = items[i].querySelector('.level-badge');
                if (badge) badge.textContent = i + 1;
            }
        }

        function addRowLevel(value = '') {
            rowContainer.appendChild(createSelectElement('rowField', value));
            rebuildBadges('rowLevelsContainer');
        }
        function addColLevel(value = '') {
            colContainer.appendChild(createSelectElement('colField', value));
            rebuildBadges('colLevelsContainer');
        }

        function toggleAggField(val) {
            const group = document.getElementById('aggFieldGroup');
            const field = document.getElementById('aggField');
            if (val === 'SUM') {
                group.style.display = 'block';
                field.setAttribute('required', 'required');
            } else {
                group.style.display = 'none';
                field.removeAttribute('required');
            }
        }

        function openModal()  { document.getElementById('settingsModal').style.display = 'block'; }
        function closeModal() { document.getElementById('settingsModal').style.display = 'none'; }
        window.onclick = function(event) {
            const modal = document.getElementById('settingsModal');
            if (event.target === modal) closeModal();
        };

        window.addEventListener('DOMContentLoaded', () => {
            if (initialRowFields && initialRowFields.length > 0) {
                initialRowFields.forEach(val => addRowLevel(val));
            } else { addRowLevel(); }
            if (initialColFields && initialColFields.length > 0) {
                initialColFields.forEach(val => addColLevel(val));
            } else { addColLevel(); }
        });

        // Dynamic printing zoom helper — no hardcoded scales!
        window.addEventListener('beforeprint', () => {
            const table = document.querySelector('table.pivot-table');
            if (table) {
                const tableWidth = table.offsetWidth;
                // Query print media query state dynamically (reflects orientation chosen in native print options!)
                const isLandscape = window.matchMedia('(orientation: landscape)').matches;
                // Target width is ~1000px for landscape, ~700px for portrait
                const targetWidth = isLandscape ? 1000 : 700;
                if (tableWidth > targetWidth) {
                    const dynamicZoom = Math.max(35, Math.min(100, Math.floor((targetWidth / tableWidth) * 100)));
                    document.body.style.setProperty('zoom', dynamicZoom + '%', 'important');
                }
            }
        });
        window.addEventListener('afterprint', () => {
            document.body.style.removeProperty('zoom');
        });
    </script>
</body>
</html>
