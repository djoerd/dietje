package nl.utwente.dietje;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;


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

}
