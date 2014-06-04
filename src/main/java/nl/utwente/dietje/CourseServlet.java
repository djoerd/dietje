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
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.ServletException;

import org.json.simple.JSONValue;

import nl.utwente.dietje.DietjeDatabase;


public class CourseServlet extends HttpServlet {

    protected void doWrite(PrintWriter writer) throws IOException {
        DietjeDatabase database = new DietjeDatabase();
        Connection connection = database.connect();
        Map resultMap = new LinkedHashMap();
        List courses = new ArrayList<Object>();
        try {
            PreparedStatement statement = connection.prepareStatement(
              "SELECT c.name, c.cid AS tag, count(DISTINCT s.sid) AS enrolled FROM course c, assignment a, submits s WHERE c.cid = a.cid AND a.aid= s.aid GROUP BY c.name, c.cid");
            ResultSet set = statement.executeQuery();
            while(set.next()) {
               Map course = new LinkedHashMap<String, Object>();
               course.put("name", set.getString("name"));
               course.put("tag", set.getString("tag"));
               course.put("enrolled", set.getInt("enrolled"));
               courses.add(course);
            }
        } catch (SQLException e) {
            throw new IOException(e);
        } finally {
            try {
                connection.close();
                database.close();
            } catch (SQLException e) { }
        }
        resultMap.put("courses", courses);
        writer.print(JSONValue.toJSONString(resultMap));
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse 
                             response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setHeader("Access-Control-Allow-Origin", "*");
        doWrite(response.getWriter());
    }
}
