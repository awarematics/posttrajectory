
public class Make_Query {
	String query;
	String modify_Query_Array_Data;
	
	Tokenize_data tokenized = new Tokenize_data();
	
	public String make_appendquery(String data, String table_name, String traj_column_name){
		tokenized.tokenize(data);
		
		query = "update " + table_name + " set " + traj_column_name + " = " +
			    "append(" + traj_column_name + ", tpoint(st_point(" + tokenized.getLatitude() + ", " + tokenized.getLongitude() + "), " +
			    "to_timestamp('" + tokenized.getDate_str() + " " + tokenized.getTime_str() + "', 'YYYY-MM-DD HH24:MI:SS') ) ) where taxi_id = " + tokenized.getOid();			
		
		return query;
	}


}
