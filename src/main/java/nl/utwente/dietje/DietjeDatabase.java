package nl.utwente.dietje;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Map;
import java.util.LinkedHashMap;

public class DietjeDatabase {

    private final static String url = 
      //"jdbc:postgresql://localhost/dietje?user=dietje&password=changeit";
      "jdbc:mysql://localhost/dietje?user=dietje&password=";

    private Connection connection;

    public DietjeDatabase() throws IOException {
        try {
            //Class.forName("org.postgresql.Driver");
            Class.forName("com.mysql.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new IOException(e);
        }
        try {
            connection = DriverManager.getConnection(url);
        } catch (SQLException e) { 
            throw new IOException(e);
        }
    }

    public Connection connect() {
        return connection;
    }

    public void close() {
        try {
           connection.close();
        } catch (SQLException e) { }
    }

    public Map getCourse(Connection connection, String courseID) throws IOException {
        Map course = new LinkedHashMap<String, Object>();
        try {
            PreparedStatement statement = connection.prepareStatement(
              "SELECT c.name, c.cid AS tag, COUNT(a.aid) AS nr_assign FROM course c, assignment a WHERE c.cid = a.cid AND c.cid = ?");
            statement.setString(1, courseID);
            ResultSet set = statement.executeQuery();
            if (set.next()) {
                course.put("name", set.getString("name"));
                course.put("tag", set.getString("tag"));
                course.put("nr_assign", set.getInt("nr_assign"));
            }
        } catch (SQLException e) {
            throw new IOException(e);
        }
        return course;
    }

    public Map getStudent(Connection connection, String courseID, String studentID) throws IOException {
        Map student  = new LinkedHashMap<String, Object>();
        try {
            PreparedStatement statement = connection.prepareStatement(
              "SELECT t.github_id AS nickname, t.realname, COUNT(CASE WHEN s.grade >= 4.5 THEN 1 END) / (SELECT COUNT(*) FROM assignment a, course c WHERE a.cid = c.cid AND c.cid = ?)  AS progress, AVG(s.grade) AS grade FROM assignment a, submits s, student t WHERE a.cid = ? AND a.aid= s.aid AND s.sid = t.sid AND t.sid = ? GROUP BY t.sid, t.realname");
            statement.setString(1, courseID);
            statement.setString(2, courseID);
            statement.setString(3, studentID);
            ResultSet set = statement.executeQuery();
            if (set.next()) {
                student.put("nickname", set.getString("nickname"));
                String realname = set.getString("realname");
                if (realname != null) { student.put("realname", realname); }
                student.put("progress", set.getFloat("progress"));
                student.put("grade", set.getFloat("grade"));
            }
        } catch (SQLException e) {
            throw new IOException(e);
        }
        return student;
    }



}
