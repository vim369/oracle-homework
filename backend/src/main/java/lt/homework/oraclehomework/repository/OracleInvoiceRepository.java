package lt.homework.oraclehomework.repository;

import java.sql.CallableStatement;
import java.sql.Clob;
import java.sql.Types;
import org.springframework.jdbc.core.ConnectionCallback;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class OracleInvoiceRepository implements InvoiceRepository {
    private final JdbcTemplate jdbcTemplate;

    public OracleInvoiceRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public String findUnpaidInvoices() {
        return jdbcTemplate.execute((ConnectionCallback<String>) connection -> {
            try (CallableStatement statement = connection.prepareCall(
                    "{ ? = call pkg_homework.get_unpaid_invoices() }")) {
                statement.registerOutParameter(1, Types.CLOB);
                statement.execute();

                Clob result = statement.getClob(1);
                return result == null ? "[]" : result.getSubString(1, (int) result.length());
            }
        });
    }
}
