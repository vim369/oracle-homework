"use strict";
const ageForm = document.querySelector('#age-form');
const ageResult = document.querySelector('#age-result');
const piForm = document.querySelector('#pi-form');
const piResult = document.querySelector('#pi-result');
const invoiceButton = document.querySelector('#invoice-load');
const invoiceResult = document.querySelector('#invoice-result');
async function requestJson(url, options) {
    const response = await fetch(url, options);
    if (!response.ok) {
        const error = await response.json().catch(() => ({}));
        throw new Error(error.details?.join('; ') ?? error.error ?? `HTTP ${response.status}`);
    }
    return response.json();
}
function showError(element, error) {
    element.classList.add('error');
    element.textContent = error instanceof Error ? error.message : 'Unexpected error';
}
ageForm.addEventListener('submit', async (event) => {
    event.preventDefault();
    ageResult.classList.remove('error');
    ageResult.textContent = 'Loading...';
    const age = Number(new FormData(ageForm).get('age'));
    try {
        const data = await requestJson(`/api/ages/${age}`);
        ageResult.textContent = `${data.description} (age ${data.age})`;
    }
    catch (error) {
        showError(ageResult, error);
    }
});
piForm.addEventListener('submit', async (event) => {
    event.preventDefault();
    piResult.classList.remove('error');
    piResult.textContent = 'Calculating...';
    const precision = Number(new FormData(piForm).get('precision'));
    try {
        const data = await requestJson('/api/pi', {
            method: 'POST', headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ precision })
        });
        piResult.textContent = `π ≈ ${data.value} (${data.precision} terms)`;
    }
    catch (error) {
        showError(piResult, error);
    }
});
invoiceButton.addEventListener('click', async () => {
    invoiceButton.disabled = true;
    invoiceResult.classList.remove('error');
    invoiceResult.textContent = 'Loading...';
    try {
        const invoices = await requestJson('/api/invoices/unpaid');
        if (invoices.length === 0) {
            invoiceResult.textContent = 'All invoices are fully paid.';
            return;
        }
        const rows = invoices.map(i => `<tr><td>${i.invoiceId}</td><td>${i.invoiceDate}</td></tr>`).join('');
        invoiceResult.innerHTML = `<table><thead><tr><th>Invoice ID</th><th>Invoice date</th></tr></thead><tbody>${rows}</tbody></table>`;
    }
    catch (error) {
        showError(invoiceResult, error);
    }
    finally {
        invoiceButton.disabled = false;
    }
});
