
public class Tokenize_data {
	
	String oid;	
	String latitude;
	String longitude;
	String date_str;
	String time_str;

	public void tokenize(String data){
		String[] result = data.split(",");

		oid = "1";
		latitude = result[0];
		longitude = result[1];		
		date_str = result[5];
		time_str = result[6];		
	}
	
	public String getOid(){
		return oid;
	}
	
	public String getLatitude(){
		return latitude;
	}
	
	public String getLongitude(){
		return longitude;
	}
	
	public String getDate_str(){
		return date_str;
	}
	
	public String getTime_str(){
		return time_str;
	}
	
}
