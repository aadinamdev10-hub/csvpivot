<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
    if (session.getAttribute("headers") == null && request.getAttribute("headers") == null) {
        response.sendRedirect(request.getContextPath() + "/apps/csvpivot/upload");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Configure Report | CSV Pivot</title>
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

        /* ── App Banner ── */
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

        /* ── Navigation Tabs Bar ── */
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
            max-width: 800px;
            margin: 0 auto;
            box-sizing: border-box;
            flex: 1;
        }

        .card {
            background: #fff;
            border: 1px solid var(--border);
            border-radius: var(--radius);
            box-shadow: 0 4px 6px -1px rgba(15, 23, 42, 0.05);
            padding: 2rem 2.5rem;
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

        .form-group { margin-bottom: 1.25rem; }
        .form-group label {
            display: block; font-size: 0.85rem; font-weight: 600;
            color: var(--text); margin-bottom: 0.45rem;
        }
        .form-control {
            width: 100%; padding: 0.6rem 0.85rem;
            border: 1.5px solid var(--border); border-radius: 6px;
            font-family: inherit; font-size: 0.875rem; color: var(--text);
            background: #fff; transition: border-color 0.15s;
            box-sizing: border-box;
        }
        .form-control:focus {
            outline: none; border-color: var(--primary);
        }

        .config-layout { display: grid; grid-template-columns: 1fr 1fr; gap: 1.5rem; margin-bottom: 1.5rem; }
        @media(max-width:580px){ .config-layout { grid-template-columns: 1fr; } }

        .config-section {
            border: 1px solid var(--border);
            border-radius: 8px;
            padding: 1.25rem;
            background: #f8fafc;
        }
        .config-section h3 {
            font-size: 0.85rem; font-weight: 700; color: var(--primary);
            text-transform: uppercase; letter-spacing: 0.06em;
            margin-bottom: 0.85rem;
            border-bottom: 1.5px solid var(--border);
            padding-bottom: 0.4rem;
        }

        .level-item { display: flex; align-items: center; gap: 0.5rem; margin-bottom: 0.6rem; }
        .level-badge {
            min-width: 22px; height: 22px; border-radius: 50%;
            background: var(--primary); color: #fff;
            font-size: 0.72rem; font-weight: 700;
            display: inline-flex; align-items: center; justify-content: center;
        }
        .btn-add-level {
            display: inline-flex; align-items: center; gap: 0.3rem;
            background: var(--primary-light); color: var(--primary); border: 1px solid #bfdbfe;
            padding: 0.4rem 0.85rem; border-radius: 5px;
            font-size: 0.8rem; font-weight: 600; cursor: pointer;
            transition: all 0.12s;
        }
        .btn-add-level:hover { background: #e0f2fe; }
        .btn-remove {
            display: inline-flex; align-items: center;
            background: #fef2f2; color: #dc2626; border: 1px solid #fca5a5;
            padding: 0.35rem 0.7rem; border-radius: 5px;
            font-size: 0.78rem; font-weight: 600; cursor: pointer;
            transition: background 0.12s;
        }
        .btn-remove:hover { background: #fee2e2; }

        .btn-submit {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 100%;
            padding: 0.75rem 1.5rem;
            background: var(--primary);
            color: #fff;
            border: none;
            border-radius: 6px;
            font-size: 0.9rem;
            font-weight: 700;
            cursor: pointer;
            box-shadow: 0 4px 10px rgba(13, 45, 119, 0.25);
            transition: background 0.15s, transform 0.1s;
        }
        .btn-submit:hover {
            background: var(--primary-dk);
            transform: translateY(-1px);
        }
        .btn-submit:active {
            transform: translateY(0);
        }

        .alert-error {
            background: #fef2f2;
            border: 1px solid #fca5a5;
            color: #b91c1c;
            padding: 0.8rem 1rem;
            border-radius: 6px;
            font-size: 0.85rem;
            font-weight: 500;
            margin-bottom: 1.25rem;
        }

        /* ── Site Footer ── */
        .site-footer {
            background: #0f172a;
            color: #475569;
            text-align: center;
            padding: 1.25rem 1rem;
            font-size: 0.78rem;
            border-top: 3px solid var(--primary);
            margin-top: 3rem;
        }
        .site-footer strong { color: #94a3b8; }
    </style>
</head>
<body class="page-body">

    <!-- Bilingual App Banner -->
    <div class="App-banner">
        <img src="${pageContext.request.contextPath}/apps/csvpivot/images/App_banner.png" class="App-logo-img" alt="App Portal Logo">
    </div>

    <!-- Navigation Tabs Bar -->
    <div class="tabs-nav">
        <a href="${pageContext.request.contextPath}/apps/csvpivot/upload">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="9"/><rect x="14" y="3" width="7" height="5"/><rect x="14" y="12" width="7" height="9"/><rect x="3" y="16" width="7" height="5"/></svg>
            Datasets Dashboard
        </a>
        <a href="#" class="active">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
            Configure Report
        </a>
        <div class="user-menu-top">
            <span class="user-menu-name">Administrator (SUPERADMIN)</span>
            <a href="${pageContext.request.contextPath}/apps/csvpivot/upload" style="color: white; border: 1px solid rgba(255, 255, 255, 0.4); background: transparent; padding: 0.35rem 0.85rem; border-radius: 4px; font-size: 0.8rem; font-weight: 600; text-decoration: none; transition: all 0.2s;" onmouseover="this.style.background='rgba(255,255,255,0.15)'" onmouseout="this.style.background='transparent'">Logout</a>
        </div>
    </div>

    <!-- Page Container -->
    <div class="page">
        <div class="card">
            
            <!-- Title Block -->
            <div class="title-block">
                <a href="${pageContext.request.contextPath}/apps/csvpivot/upload" class="btn-back">
                    &larr; Back
                </a>
                <h1>Configure Report Parameters</h1>
            </div>

            <!-- Error message if any -->
            <c:if test="${not empty error}">
                <div class="alert-error">
                    <strong>Error:</strong> ${error}
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/apps/csvpivot/settings/save" method="POST" id="configForm">
                <!-- Pass identifying dataset and configuration IDs -->
                <input type="hidden" name="configId" value="${config.id}">
                <input type="hidden" name="datasetId" value="${datasetId}">
                
                <!-- Report Name -->
                <div class="form-group">
                    <label for="configName">Report Title Name *</label>
                    <input type="text" name="configName" id="configName" class="form-control" 
                           value="${not empty config.name ? config.name : (not empty configName ? configName : 'Pivot Table Report')}" 
                           placeholder="e.g. Department Wise Category Report" required>
                </div>

                <!-- Aggregation Function Selection -->
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1.5rem; margin-bottom: 1.5rem;">
                    <div class="form-group" style="margin-bottom: 0;">
                        <label for="aggType">Aggregation Function *</label>
                        <select name="aggType" id="aggType" class="form-control" onchange="toggleAggField(this.value)">
                            <option value="COUNT" ${(config.aggType == 'COUNT' || aggType == 'COUNT') ? 'selected' : ''}>COUNT (Total Records Count)</option>
                            <option value="SUM" ${(config.aggType == 'SUM' || aggType == 'SUM') ? 'selected' : ''}>SUM (Sum of Column Values)</option>
                        </select>
                    </div>
                    <div class="form-group" id="aggFieldGroup" style="margin-bottom: 0; display: ${(config.aggType == 'SUM' || aggType == 'SUM') ? 'block' : 'none'};">
                        <label for="aggField">Select Column to Sum *</label>
                        <select name="aggField" id="aggField" class="form-control">
                            <c:forEach var="h" items="${headers}">
                                <option value="${h}" ${(config.aggField == h || aggField == h) ? 'selected' : ''}>${h}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>

                <!-- Row and Column Nesting Configurations -->
                <div class="config-layout">
                    <!-- Row Levels -->
                    <div class="config-section">
                        <h3>Row Levels (Nesting)</h3>
                        <div id="rowLevelsContainer"></div>
                        <button type="button" class="btn-add-level" onclick="addRowLevel()">+ Add Row Dimension</button>
                    </div>

                    <!-- Column Levels -->
                    <div class="config-section">
                        <h3>Column Levels (Nesting)</h3>
                        <div id="colLevelsContainer"></div>
                        <button type="button" class="btn-add-level" onclick="addColLevel()">+ Add Column Dimension</button>
                    </div>
                </div>

                <!-- Submit Button -->
                <button type="submit" class="btn-submit">
                    Generate Pivot Table Report &rarr;
                </button>
            </form>
        </div>
    </div>

    <!-- Footer -->
    <footer class="site-footer">
        <p>&copy; 2026 <strong>Application Portal, Main Campus</strong>. All Rights Reserved.</p>
    </footer>

    <!-- Form JavaScript Logic -->
    <script>
        const availableHeaders = [
            <c:forEach items="${headers}" var="h" varStatus="status">
                "${h}"<c:if test="${!status.last}">,</c:if>
            </c:forEach>
        ];

        // Retrieve initial row levels from database config or request context
        const initialRowFields = [
            <c:choose>
                <c:when test="${not empty config.rowFields}">
                    <c:forEach items="${config.rowFields}" var="f" varStatus="status">
                        "${f}"<c:if test="${!status.last}">,</c:if>
                    </c:forEach>
                </c:when>
                <c:when test="${not empty selectedRowFields}">
                    <c:forEach items="${selectedRowFields}" var="f" varStatus="status">
                        "${f}"<c:if test="${!status.last}">,</c:if>
                    </c:forEach>
                </c:when>
            </c:choose>
        ];

        // Retrieve initial column levels from database config or request context
        const initialColFields = [
            <c:choose>
                <c:when test="${not empty config.colFields}">
                    <c:forEach items="${config.colFields}" var="f" varStatus="status">
                        "${f}"<c:if test="${!status.last}">,</c:if>
                    </c:forEach>
                </c:when>
                <c:when test="${not empty selectedColFields}">
                    <c:forEach items="${selectedColFields}" var="f" varStatus="status">
                        "${f}"<c:if test="${!status.last}">,</c:if>
                    </c:forEach>
                </c:when>
            </c:choose>
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
            if (val === 'SUM') {
                group.style.display = 'block';
                document.getElementById('aggField').setAttribute('required', 'required');
            } else {
                group.style.display = 'none';
                document.getElementById('aggField').removeAttribute('required');
            }
        }

        // Initialize selectors on page load
        window.addEventListener('DOMContentLoaded', () => {
            if (initialRowFields && initialRowFields.length > 0) {
                initialRowFields.forEach(val => addRowLevel(val));
            } else {
                addRowLevel();
            }
            
            if (initialColFields && initialColFields.length > 0) {
                initialColFields.forEach(val => addColLevel(val));
            } else {
                addColLevel();
            }
        });
    </script>
</body>
</html>