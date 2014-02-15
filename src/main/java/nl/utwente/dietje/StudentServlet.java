package nl.utwente.dietje;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.LinkedHashMap;
import java.util.Map;

import javax.servlet.http.HttpServlet;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.simple.JSONValue;


public class StudentServlet extends HttpServlet {

    private Map getCourse(Connection connection, String courseID) throws IOException {
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
        
    private List getStudents(Connection connection, String courseID, Integer nr_assign) throws IOException { 
        List students  = new ArrayList<Object>();
        try {
            PreparedStatement statement = connection.prepareStatement( 
              "SELECT t.sid AS nickname, t.realname, COUNT(CASE WHEN s.grade >= 3.5 THEN 1 END) / ? AS progress, AVG(s.grade) AS grade FROM assignment a, submits s, student t WHERE a.cid = ? AND a.aid= s.aid AND s.sid = t.sid GROUP BY t.sid, t.realname");
            statement.setInt(1, nr_assign);
            statement.setString(2, courseID);
            ResultSet set = statement.executeQuery();
            while (set.next()) {
                Map student = new LinkedHashMap<String, Object>();
                student.put("nickname", set.getString("nickname"));
                String realname = set.getString("realname");
                if (realname != null) { student.put("realname", realname); }
                student.put("progress", set.getFloat("progress"));
                student.put("grade", set.getFloat("grade")); 
                students.add(student);
            }
        } catch (SQLException e) {
            throw new IOException(e);
        }
        return students;
    }

    /** 
     * Protected to allow unit testing
     */
    protected void doWrite(PrintWriter writer, String courseID) throws IOException {
        DietjeDatabase database = new DietjeDatabase();
        Connection connection = database.connect();
        Map resultMap = new LinkedHashMap<String, Object>();
        Map course = getCourse(connection, courseID);
        resultMap.put("course", course);
        Integer nr_assign = (Integer) course.get("nr_assign");
        if (nr_assign != null) {
            List students = getStudents(connection, courseID, nr_assign);
            resultMap.put("students", students);
        }
        writer.print(JSONValue.toJSONString(resultMap));
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse 
                           response) throws ServletException, IOException {
        response.setContentType("application/json");
        doWrite(response.getWriter(), request.getParameter("course"));
    }
}
