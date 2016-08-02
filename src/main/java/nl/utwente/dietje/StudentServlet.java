package nl.utwente.dietje;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.LinkedHashMap;
import java.util.Map;

import javax.servlet.http.HttpServlet;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.simple.JSONValue;

import nl.utwente.dietje.DietjeDatabase;


public class StudentServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private List<Map<String, Object>> getStudents(Connection connection, String courseID) throws SQLException { 
        List<Map<String, Object>> students  = new ArrayList<Map<String, Object>>();
        PreparedStatement statement = connection.prepareStatement( 
          "SELECT t.sid AS nickname, t.realname, SUM(CASE WHEN s.grade >= 3.5 THEN 100 ELSE 0 END) / (SELECT COUNT(*) FROM assignment a, course c WHERE a.cid = c.cid AND c.cid = ?) AS progress, AVG(s.grade) AS grade FROM assignment a, submits s, student t WHERE a.cid = ? AND a.aid= s.aid AND s.sid = t.sid GROUP BY t.sid, t.realname ORDER BY progress DESC, grade DESC, nickname ASC");
        statement.setString(1, courseID);
        statement.setString(2, courseID);
        ResultSet set = statement.executeQuery();
        while (set.next()) {
            Map<String, Object> student = new LinkedHashMap<String, Object>();
            student.put("nickname", set.getString("nickname"));
            String realname = set.getString("realname");
            if (realname != null) { student.put("realname", realname); }
            Float progress = set.getFloat("progress");
            if (progress != null) { student.put("progress", Math.round(progress)); }
            Float grade = set.getFloat("grade");
            if (grade != null && grade > 0.0) { student.put("grade", grade); }
            students.add(student);
        }
        return students;
    }

    /** 
     * Protected to allow unit testing
     */
    protected void doWrite(PrintWriter writer, String courseID) throws IOException {
        DietjeDatabase database = null;
        Connection connection = null;
        Map<String, Object> resultMap = new LinkedHashMap<String, Object>();
        try {
            database = new DietjeDatabase();
            connection = database.connect();
            Map<String, Object> course = database.getCourse(connection, courseID);
            resultMap.put("course", course);
            if (course.containsKey("tag")) {
                List<Map<String, Object>> students = getStudents(connection, courseID);
                resultMap.put("students", students);
            }
        } catch (SQLException e) {
            throw new IOException(e);
        } finally {
            try {
                connection.close();
                database.close();
            } catch (SQLException e) { }
        }
        writer.print(JSONValue.toJSONString(resultMap));
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse 
                           response) throws ServletException, IOException {
        response.setContentType("application/json");
        doWrite(response.getWriter(), request.getParameter("course"));
    }
}
