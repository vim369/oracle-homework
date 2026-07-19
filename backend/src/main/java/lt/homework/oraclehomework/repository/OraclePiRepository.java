package lt.homework.oraclehomework.repository;

import java.math.BigDecimal;
import java.sql.CallableStatement;
import java.sql.Types;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class OraclePiRepository implements PiRepository {
    private final JdbcTemplate jdbcTemplate;

    public OraclePiRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public BigDecimal calculate(int precision) {
        return jdbcTemplate.execute(connection -> {
            CallableStatement statement = connection.prepareCall("{ ? = call pkg_homework.calculate_pi(?) }");
            statement.registerOutParameter(1, Types.NUMERIC);
            statement.setInt(2, precision);
            return statement;
        }, statement -> {
            statement.execute();
            return statement.getBigDecimal(1);
        });
    }
}
