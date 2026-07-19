package lt.homework.oraclehomework.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.when;

import lt.homework.oraclehomework.repository.InvoiceRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class InvoiceServiceTest {
    @Mock InvoiceRepository repository;
    @InjectMocks InvoiceService service;

    @Test
    void returnsRepositoryResult() {
        String json = "[{\"invoiceId\":1002,\"invoiceDate\":\"2026-01-11\"}]";
        when(repository.findUnpaidInvoices()).thenReturn(json);

        assertThat(service.findUnpaidInvoices()).isEqualTo(json);
    }
}
