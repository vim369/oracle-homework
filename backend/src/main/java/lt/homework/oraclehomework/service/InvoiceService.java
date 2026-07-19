package lt.homework.oraclehomework.service;

import lt.homework.oraclehomework.repository.InvoiceRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class InvoiceService {
    private final InvoiceRepository repository;

    public InvoiceService(InvoiceRepository repository) {
        this.repository = repository;
    }

    @Transactional(readOnly = true)
    public String findUnpaidInvoices() {
        return repository.findUnpaidInvoices();
    }
}
