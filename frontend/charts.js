/* ============================================================
   Advanced Supply Chain Risk Analysis System — Charts & API
   ============================================================ */

const API_BASE = 'http://localhost:5001';

/* --- Helper: Fetch JSON from API --- */
async function fetchData(endpoint) {
    const response = await fetch(`${API_BASE}${endpoint}`);
    if (!response.ok) throw new Error(`API error: ${response.status}`);
    return response.json();
}

/* --- Status Badge HTML --- */
function getStatus(arrivalDate) {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const arrival = new Date(arrivalDate);
    return arrival <= today ? 'Delivered' : 'In Transit';
}

function statusBadge(arrivalDate) {
    const status = getStatus(arrivalDate);
    const cls = status === 'Delivered' ? 'badge-delivered' : 'badge-transit';
    return `<span class="badge ${cls}">${status}</span>`;
}

/* --- Risk Flag Badge HTML --- */
function riskBadge(flag) {
    return flag
        ? '<span class="badge badge-risk">High Risk</span>'
        : '<span class="badge badge-safe">Normal</span>';
}

/* ============================================================
   DASHBOARD PAGE
   ============================================================ */
async function loadDashboard() {
    try {
        const [shipments, avgDelay, carrierPerf] = await Promise.all([
            fetchData('/shipments'),
            fetchData('/avg-delay-route'),
            fetchData('/carrier-performance')
        ]);

        // --- Summary Metrics ---
        const totalShipments = shipments.length;
        const highRiskCount = shipments.filter(s => s.delay_flag === 1).length;
        const avgDelayAll = shipments.length > 0
            ? (shipments.reduce((sum, s) => sum + s.actual_delay_hours, 0) / shipments.length).toFixed(1)
            : 0;
        const deliveredCount = shipments.filter(s => getStatus(s.arrival_date) === 'Delivered').length;

        document.getElementById('metric-total').textContent = totalShipments;
        document.getElementById('metric-highrisk').textContent = highRiskCount;
        document.getElementById('metric-avgdelay').textContent = avgDelayAll;
        document.getElementById('metric-delivered').textContent = deliveredCount;

        // --- Chart 1: Average Delay per Route (Bar Chart) ---
        const routeLabels = avgDelay.map(r => `${r.origin} → ${r.destination}`);
        const routeDelays = avgDelay.map(r => parseFloat(r.avg_delay_hours));

        const routeColors = routeDelays.map(d =>
            d > 60 ? '#e74c3c' : d > 24 ? '#ffc107' : '#2ecc71'
        );

        new Chart(document.getElementById('chart-route-delay'), {
            type: 'bar',
            data: {
                labels: routeLabels,
                datasets: [{
                    label: 'Avg Delay (hours)',
                    data: routeDelays,
                    backgroundColor: routeColors,
                    borderRadius: 4
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: { display: false }
                },
                scales: {
                    x: {
                        ticks: { font: { size: 10 }, maxRotation: 45 }
                    },
                    y: {
                        beginAtZero: true,
                        title: { display: true, text: 'Hours' }
                    }
                }
            }
        });

        // --- Chart 2: Carrier Performance (Horizontal Bar) ---
        const carrierLabels = carrierPerf.map(c => c.carrier_name);
        const carrierDelays = carrierPerf.map(c => parseFloat(c.avg_delay_hours));
        const carrierReliability = carrierPerf.map(c => c.reliability_score);

        new Chart(document.getElementById('chart-carrier-perf'), {
            type: 'bar',
            data: {
                labels: carrierLabels,
                datasets: [
                    {
                        label: 'Avg Delay (hours)',
                        data: carrierDelays,
                        backgroundColor: '#e74c3c',
                        borderRadius: 4
                    },
                    {
                        label: 'Reliability Score (x10)',
                        data: carrierReliability.map(r => r * 10),
                        backgroundColor: '#4dabf7',
                        borderRadius: 4
                    }
                ]
            },
            options: {
                responsive: true,
                indexAxis: 'y',
                scales: {
                    x: { beginAtZero: true }
                },
                plugins: {
                    legend: { position: 'bottom' }
                }
            }
        });

    } catch (err) {
        console.error('Dashboard load error:', err);
    }
}

/* ============================================================
   SHIPMENTS PAGE
   ============================================================ */
async function loadShipments() {
    try {
        const shipments = await fetchData('/shipments');
        const tbody = document.getElementById('shipments-tbody');
        const searchInput = document.getElementById('filter-search');
        const statusFilter = document.getElementById('filter-status');
        const cargoFilter = document.getElementById('filter-cargo');

        // Populate filter dropdowns
        const statuses = [...new Set(shipments.map(s => getStatus(s.arrival_date)))];
        const cargoTypes = [...new Set(shipments.map(s => s.cargo_type))].sort();

        statuses.forEach(st => {
            const opt = document.createElement('option');
            opt.value = st;
            opt.textContent = st;
            statusFilter.appendChild(opt);
        });

        cargoTypes.forEach(ct => {
            const opt = document.createElement('option');
            opt.value = ct;
            opt.textContent = ct;
            cargoFilter.appendChild(opt);
        });

        function renderTable() {
            const search = searchInput.value.toLowerCase();
            const status = statusFilter.value;
            const cargo = cargoFilter.value;

            const filtered = shipments.filter(s => {
                const matchSearch = !search
                    || s.carrier_name.toLowerCase().includes(search)
                    || s.origin_port.toLowerCase().includes(search)
                    || s.destination_port.toLowerCase().includes(search);
                const matchStatus = !status || getStatus(s.arrival_date) === status;
                const matchCargo = !cargo || s.cargo_type === cargo;
                return matchSearch && matchStatus && matchCargo;
            });

            const statusOptions = ['In Transit', 'Delivered'];

            tbody.innerHTML = filtered.map(s => `
                <tr>
                    <td>${s.shipment_id}</td>
                    <td>${s.origin_port}</td>
                    <td>${s.destination_port}</td>
                    <td>${s.carrier_name}</td>
                    <td>${s.cargo_type}</td>
                    <td>${s.weight_kg.toLocaleString()} kg</td>
                    <td>${s.departure_date}</td>
                    <td>${s.arrival_date}</td>
                    <td>${s.actual_delay_hours}h</td>
                    <td>${riskBadge(s.delay_flag)}</td>
                    <td>${statusBadge(s.arrival_date)}</td>
                    <td>
                        <select class="status-select" data-id="${s.shipment_id}">
                            ${statusOptions.map(opt =>
                                `<option value="${opt}" ${s.current_status === opt ? 'selected' : ''}>${opt}</option>`
                            ).join('')}
                        </select>
                    </td>
                </tr>
            `).join('');

            tbody.querySelectorAll('.status-select').forEach(select => {
                select.addEventListener('change', async (e) => {
                    const shipmentId = e.target.dataset.id;
                    const newStatus = e.target.value;
                    try {
                        const res = await fetch(`${API_BASE}/update-status`, {
                            method: 'PUT',
                            headers: { 'Content-Type': 'application/json' },
                            body: JSON.stringify({ shipment_id: shipmentId, status: newStatus })
                        });
                        const data = await res.json();
                        if (!res.ok) {
                            alert(data.error || 'Failed to update status');
                            renderTable();
                        }
                    } catch (err) {
                        alert('Error updating status');
                        renderTable();
                    }
                });
            });
        }

        searchInput.addEventListener('input', renderTable);
        statusFilter.addEventListener('change', renderTable);
        cargoFilter.addEventListener('change', renderTable);

        renderTable();
    } catch (err) {
        console.error('Shipments load error:', err);
    }
}

/* ============================================================
   RISK ANALYSIS PAGE
   ============================================================ */
async function loadRiskAnalysis() {
    try {
        const [highRisk, ranked, aboveAvg, weatherCorr] = await Promise.all([
            fetchData('/high-risk'),
            fetchData('/ranked-shipments'),
            fetchData('/above-avg-delay'),
            fetchData('/weather-correlation')
        ]);

        // --- High Risk Table ---
        const highRiskTbody = document.getElementById('highrisk-tbody');
        highRiskTbody.innerHTML = highRisk.map(s => {
            const dep = new Date(s.departure_date);
            const expectedArrival = new Date(dep.getTime() + s.expected_duration_hours * 3600000);
            const expectedStr = expectedArrival.toISOString().split('T')[0];

            return `<tr>
                <td>${s.shipment_id}</td>
                <td>${s.carrier_name}</td>
                <td>${s.cargo_type}</td>
                <td>${s.departure_date}</td>
                <td>${expectedStr}</td>
                <td>${s.arrival_date}</td>
                <td><strong>${s.actual_delay_hours}h</strong></td>
                <td>${s.distance_km.toLocaleString()} km</td>
                <td>${statusBadge(s.arrival_date)}</td>
            </tr>`;
        }).join('');

        // --- Above Average Delay Table ---
        const aboveAvgTbody = document.getElementById('aboveavg-tbody');
        aboveAvgTbody.innerHTML = aboveAvg.map(s => `
            <tr>
                <td>${s.shipment_id}</td>
                <td>${s.origin} → ${s.destination}</td>
                <td>${s.carrier_name}</td>
                <td>${s.cargo_type}</td>
                <td>${s.departure_date}</td>
                <td>${s.arrival_date}</td>
                <td><strong>${s.actual_delay_hours}h</strong></td>
            </tr>
        `).join('');

        // --- Weather Correlation Table ---
        const weatherTbody = document.getElementById('weather-tbody');
        weatherTbody.innerHTML = weatherCorr.map(s => `
            <tr>
                <td>${s.shipment_id}</td>
                <td>${s.origin} → ${s.destination}</td>
                <td>${s.carrier_name}</td>
                <td>${s.departure_date}</td>
                <td><strong>${s.actual_delay_hours}h</strong></td>
                <td>${s.weather_type}</td>
                <td>${s.severity_level}/10</td>
                <td>${s.weather_date}</td>
                <td>${s.affected_port}</td>
            </tr>
        `).join('');

        // --- Ranked Shipments Table ---
        const rankedTbody = document.getElementById('ranked-tbody');
        rankedTbody.innerHTML = ranked.map(s => `
            <tr>
                <td class="rank-cell">#${s.delay_rank}</td>
                <td>${s.shipment_id}</td>
                <td>${s.carrier_name}</td>
                <td>${s.cargo_type}</td>
                <td>${s.actual_delay_hours}h</td>
                <td>#${s.route_rank}</td>
            </tr>
        `).join('');

    } catch (err) {
        console.error('Risk analysis load error:', err);
    }
}

/* ============================================================
   ADD SHIPMENT PAGE
   ============================================================ */
async function loadAddShipmentForm() {
    const form = document.getElementById('add-shipment-form');
    const alertSuccess = document.getElementById('alert-success');
    const alertError = document.getElementById('alert-error');

    form.addEventListener('submit', async (e) => {
        e.preventDefault();
        alertSuccess.style.display = 'none';
        alertError.style.display = 'none';

        const data = {
            route_id: parseInt(document.getElementById('route_id').value),
            carrier_id: parseInt(document.getElementById('carrier_id').value),
            departure_date: document.getElementById('departure_date').value,
            arrival_date: document.getElementById('arrival_date').value,
            cargo_type: document.getElementById('cargo_type').value,
            weight_kg: parseFloat(document.getElementById('weight_kg').value)
        };

        // Client-side validation
        if (!data.route_id || !data.carrier_id || !data.departure_date || !data.arrival_date || !data.cargo_type || !data.weight_kg) {
            alertError.textContent = 'All fields are required.';
            alertError.style.display = 'block';
            return;
        }

        if (data.arrival_date <= data.departure_date) {
            alertError.textContent = 'Arrival date must be after departure date.';
            alertError.style.display = 'block';
            return;
        }

        if (data.weight_kg <= 0) {
            alertError.textContent = 'Weight must be a positive number.';
            alertError.style.display = 'block';
            return;
        }

        try {
            const response = await fetch(`${API_BASE}/add-shipment`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(data)
            });

            const result = await response.json();

            if (response.ok) {
                alertSuccess.textContent = result.message;
                alertSuccess.style.display = 'block';
                form.reset();
            } else {
                alertError.textContent = result.error;
                alertError.style.display = 'block';
            }
        } catch (err) {
            alertError.textContent = 'Server connection failed. Is the backend running?';
            alertError.style.display = 'block';
        }
    });
}
