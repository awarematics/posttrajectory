package com.postTraj.Query;


public class Tokenize_data {

	String oid;
	String latitude;
	String longitude;
	String date_str;	

	public void tokenize(String data) {
		String[] result = data.split(",");

		oid = result[0];
		latitude = result[2];
		longitude = result[3];
		date_str = result[1];	
	}

	public String getOid() {
		return oid;
	}

	public String getLatitude() {
		return latitude;
	}

	public String getLongitude() {
		return longitude;
	}

	public String getDate_str() {
		return date_str;
	}
}
