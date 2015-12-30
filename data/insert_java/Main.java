
import java.io.*;
import java.sql.*;

public class Main {
	String file_name;
	String table_name;
	ResultSet rs;
	
	DBConnector dbconn = new DBConnector();
	
	BufferedReader in;
	
	public void data_insert(){

			Make_Query query = new Make_Query();
					
			file_name = "D:\\test.plt";
			
			try {
				in = new BufferedReader(new FileReader(file_name));
			} catch (FileNotFoundException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			
			String data;
			
			try {
				while( (data = in.readLine()) != null){
					
					dbconn.queryUpdate(query.make_appendquery(data, "taxi", "traj"));
					
//					System.out.println(query.make_appendquery(data, "taxi", "traj"));
				}
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			
	}
	

	public void dbcon(){
		if(dbconn.dbconnector()){
			System.out.println("연결 성공");
		}else{
			System.out.println("에러");
		}
	}
	
	public void dbclose(){
		dbconn.closeDB();
	}
	
	
	public static void main(String[] args) throws IOException, SQLException{
		
		Main main = new Main();
		
		main.dbcon();
		
		//데이터 삽입
		main.data_insert();
		
	}
}
