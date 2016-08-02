package nl.utwente.dietje;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Map;
import java.util.LinkedHashMap;

public class DietjeDatabase {

    private final static String url = 
      //"jdbc:mysql://localhost/dietje?user=dietje&password=";
      "jdbc:postgresql://localhost/dietje?user=dietje&password=dietje";

    private Connection connection;

    public DietjeDatabase() throws SQLException {
        try {
            //Class.forName("com.mysql.jdbc.Driver");
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException(e);
        }
        connection = DriverManager.getConnection(url);
    }

    public Connection connect() {
        return connection;
    }

    public void close() {
        try {
           connection.close();
        } catch (SQLException e) { }
    }

    public Map<String, Object> getCourse(Connection connection, String courseID) throws SQLException {
        Map<String, Object> course = new LinkedHashMap<String, Object>();
        PreparedStatement statement = connection.prepareStatement(
          "SELECT c.name, c.cid AS tag, COUNT(a.aid) AS nr_assign FROM course c, assignment a WHERE c.cid = a.cid AND c.cid = ? GROUP BY c.name, c.cid");
        statement.setString(1, courseID);
        ResultSet set = statement.executeQuery();
        if (set.next()) {
            course.put("name", set.getString("name"));
            course.put("tag", set.getString("tag"));
            course.put("nr_assign", set.getInt("nr_assign"));
        }
        return course;
    }

    public Map<String, Object> getStudent(Connection connection, String courseID, String nickname) throws SQLException {
        Map<String, Object> student  = new LinkedHashMap<String, Object>();
        PreparedStatement statement = connection.prepareStatement(
          "SELECT t.sid AS nickname, t.realname, SUM(CASE WHEN s.grade >= 4.5 THEN 100 ELSE 0 END) / (SELECT COUNT(*) FROM assignment a, course c WHERE a.cid = c.cid AND c.cid = ?)  AS progress, AVG(s.grade) AS grade FROM assignment a, submits s, student t WHERE a.cid = ? AND a.aid= s.aid AND s.sid = t.sid AND t.sid = ? GROUP BY t.sid, t.realname");
        statement.setString(1, courseID);
        statement.setString(2, courseID);
        statement.setString(3, nickname);
        ResultSet set = statement.executeQuery();
        if (set.next()) {
            student.put("nickname", set.getString("nickname"));
            String realname = set.getString("realname");
            if (realname != null) { student.put("realname", realname); }
            Float progress = set.getFloat("progress");
            if (progress != null) { student.put("progress", Math.round(progress)); }
            Float grade = set.getFloat("grade");
            if (grade != null && grade > 0.0) { student.put("grade", grade); }
        }
        return student;
    }



}
