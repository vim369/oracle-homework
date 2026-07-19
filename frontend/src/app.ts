interface AgeResponse { age: number; description: string; }
interface PiResponse { precision: number; value: number; }
interface UnpaidInvoice { invoiceId: number; invoiceDate: string; }
interface ApiError { details?: string[]; error?: string; }

const ageForm = document.querySelector<HTMLFormElement>('#age-form')!;
const ageResult = document.querySelector<HTMLOutputElement>('#age-result')!;
const piForm = document.querySelector<HTMLFormElement>('#pi-form')!;
const piResult = document.querySelector<HTMLOutputElement>('#pi-result')!;
const invoiceButton = document.querySelector<HTMLButtonElement>('#invoice-load')!;
const invoiceResult = document.querySelector<HTMLDivElement>('#invoice-result')!;

async function requestJson<T>(url: string, options?: RequestInit): Promise<T> {
  const response = await fetch(url, options);
  if (!response.ok) {
    const error = await response.json().catch(() => ({} as ApiError)) as ApiError;
    throw new Error(error.details?.join('; ') ?? error.error ?? `HTTP ${response.status}`);
  }
  return response.json() as Promise<T>;
}

function showError(element: HTMLElement, error: unknown): void {
  element.classList.add('error');
  element.textContent = error instanceof Error ? error.message : 'Unexpected error';
}

ageForm.addEventListener('submit', async event => {
  event.preventDefault();
  ageResult.classList.remove('error');
  ageResult.textContent = 'Loading...';
  const age = Number(new FormData(ageForm).get('age'));
  try {
    const data = await requestJson<AgeResponse>(`/api/ages/${age}`);
    ageResult.textContent = `${data.description} (age ${data.age})`;
  } catch (error) { showError(ageResult, error); }
});

piForm.addEventListener('submit', async event => {
  event.preventDefault();
  piResult.classList.remove('error');
  piResult.textContent = 'Calculating...';
  const precision = Number(new FormData(piForm).get('precision'));
  try {
    const data = await requestJson<PiResponse>('/api/pi', {
      method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ precision })
    });
    piResult.textContent = `π ≈ ${data.value} (${data.precision} terms)`;
  } catch (error) { showError(piResult, error); }
});

invoiceButton.addEventListener('click', async () => {
  invoiceButton.disabled = true;
  invoiceResult.classList.remove('error');
  invoiceResult.textContent = 'Loading...';
  try {
    const invoices = await requestJson<UnpaidInvoice[]>('/api/invoices/unpaid');
    if (invoices.length === 0) { invoiceResult.textContent = 'All invoices are fully paid.'; return; }
    const rows = invoices.map(i => `<tr><td>${i.invoiceId}</td><td>${i.invoiceDate}</td></tr>`).join('');
    invoiceResult.innerHTML = `<table><thead><tr><th>Invoice ID</th><th>Invoice date</th></tr></thead><tbody>${rows}</tbody></table>`;
  } catch (error) { showError(invoiceResult, error); }
  finally { invoiceButton.disabled = false; }
});
