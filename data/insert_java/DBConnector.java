import java.sql.*;


public class DBConnector {
	
	String query = "";
	Connection conn;
	String url = "";
	String username;
	String password;
	
	Statement stm;
	ResultSet rs;
	
	boolean success;
	
	
	public boolean dbconnector(){
		url = "jdbc:postgresql://localhost/postTraj";
		username = "postgres";
		password = "1";
		success = false;
		try {
			Class.forName("org.postgresql.Driver");
			conn = DriverManager.getConnection(url, username, password);
			success = true;
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
		} catch (SQLException ee) {
			ee.printStackTrace();
		}
		
		return success;
	}
	
	public void closeDB(){
		try {
			conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	
	}
	
	public void queryUpdate(String data){
		try{
			stm = conn.createStatement();
			if(stm.executeUpdate(data) != 0){
				
			}
		}catch(SQLException e){
			e.printStackTrace();
		}
		
	}
	public ResultSet queryExecute(String data){
		System.out.println(data);
		try{
			stm = conn.createStatement();
			rs = stm.executeQuery(data);
		}catch(SQLException e){
			e.printStackTrace();
		}
		
		return rs;
	}
}


