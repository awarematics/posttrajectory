
public class Make_Query {
	String query;
	String modify_Query_Array_Data;

	Tokenize_data tokenized = new Tokenize_data();

	public String get_seqNum(String table_name) {
		
		query = "select currval('taxi_traj_mpointid_seq');";

		return query;
	}
	
	public String find_TaxiNum(String data, String table_name) {
		tokenized.tokenize(data);

		query = "select count(*) from " + table_name + " where taxi_number = '" + tokenized.getOid() + "';";

		return query;
	}

	public String find_MaxId(String maxId, String table_name) {

		query = "select Max(" + maxId + ") from " + table_name;

		return query;
	}

	public String insert_Taxi(String data, String table_name, int idx) {
		tokenized.tokenize(data);

		query = "insert into " + table_name + " values (" + idx + ", '" + tokenized.getOid() + "', '"
				+ tokenized.getOid() + "', '" + tokenized.getOid() + "');";

		return query;
	}

	public String insert_traj(int mpId, int segId, int next_segId, int before_segId, int mpCnt, String rect,
			String start_time, String end_time, String tpseg) {

		query = "insert into mpseq_18646_traj values (" + mpId + ", " + segId + ", " + next_segId + ", " + before_segId
				+ ", " + mpCnt + ", " + rect + ", timestamp '" + start_time + "', timestamp '" + end_time + "', "
				+ tpseg + ");";

		return query;
	}

	public String make_polygon(String q) {

		query = "box2d(ST_GeomFromText('LINESTRING(" + q + ")'))";

		return query;
	}

	public String make_tpseg(String q) {

		query = "ARRAY[ " + q + " ]::tpoint[]";

		return query;
	}

	public String make_appendquery(String data, String table_name, String traj_column_name) {
		tokenized.tokenize(data);

		query = "update " + table_name + " set " + traj_column_name + " = " + "append(" + traj_column_name
				+ ", tpoint(st_point(" + tokenized.getLatitude() + ", " + tokenized.getLongitude() + "), "
				+ "timestamp '" + tokenized.getDate_str() + "' ) ) where taxi_number = '" + tokenized.getOid() + "';";

		return query;
	}

}
