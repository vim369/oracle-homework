package lt.homework.oraclehomework.repository;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class OracleAgeRepository implements AgeRepository {
    private final JdbcTemplate jdbcTemplate;

    public OracleAgeRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public String findDescription(int age) {
        return jdbcTemplate.queryForObject(
                "select pkg_homework.get_age_description(?) from dual",
                String.class,
                age
        );
    }
}
