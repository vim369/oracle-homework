package lt.homework.oraclehomework.controller;

import lt.homework.oraclehomework.service.InvoiceService;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/invoices")
public class InvoiceController {
    private final InvoiceService service;

    public InvoiceController(InvoiceService service) {
        this.service = service;
    }

    @GetMapping(value = "/unpaid", produces = MediaType.APPLICATION_JSON_VALUE)
    public String findUnpaid() {
        return service.findUnpaidInvoices();
    }
}
