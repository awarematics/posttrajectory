import java.io.*;
import java.sql.*;
import java.util.Arrays;

public class Main {
	File[] file_name;
	String table_name;
	ResultSet rs, rs1;

	DBConnector dbconn = new DBConnector();

	BufferedReader in;

	public File[] get_fileArr(String path) {

		File f = new File(path);

		File[] result = new File[1];

		File[] pathArr = f.listFiles();

		File tmp_file;
		String dir_name = "";

		for (int i = 0; i < pathArr.length; i++) {

			if (pathArr[i].isDirectory()) {
				if (pathArr[i].getAbsolutePath().length() != 5) {

					dir_name = pathArr[i].getName();

					for (; dir_name.length() < 5;) {
						dir_name = "0" + dir_name;
					}
					tmp_file = new File(pathArr[i].getAbsolutePath());
					tmp_file.renameTo(new File(pathArr[i].getParent() + "/" + dir_name));

				} else {
					tmp_file = new File(pathArr[i].getAbsolutePath());
				}
			}
		}

		Arrays.sort(pathArr);

		int total = 0;

		for (int i = 0; i < pathArr.length; i++) {
			if (pathArr[i].isDirectory()) {
				// System.out.println(pathArr[i].getAbsolutePath());
				total += pathArr[i].list().length;
			} else {
				total++;
			}
		}
		// System.out.println(total);

		result = new File[total];

		File[] tmpArr;
		int srcPos = 0;

		for (int i = 0; i < pathArr.length; i++) {
			tmpArr = pathArr[i].listFiles();

			Arrays.sort(tmpArr);
			for (int j = 0; j < tmpArr.length; j++) {
				result[srcPos] = tmpArr[j];
				srcPos++;
			}
		}

		for (int i = 0; i < result.length; i++) {
			System.out.println(i + " : " + result[i]);
		}

		return result;
	}

	public void data_insert(int cnt) {

		long start = System.currentTimeMillis();

		int segId = 0, next_segId = 0, before_segId = 0, mpId = 0;

		String start_time = "", end_time = "";

		Make_Query query = new Make_Query();

		String filePath = "/root/DataSet/";
		file_name = get_fileArr(filePath);

		for (int t = 0; t < file_name.length; t++) {
			// System.out.println(file_name[t].getAbsolutePath());
			try {
				in = new BufferedReader(new FileReader(file_name[t]));
			} catch (FileNotFoundException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}

			int print_cnt = 0;

			segId = 0;

			String data;

			boolean isTaxiNum = false;

			try {

				int tp_cnt = 0;

				String ptArr = "", tpArr = "", start_pt = "";

				Tokenize_data tokenized = new Tokenize_data();

				while ((data = in.readLine()) != null) {

					if (!isTaxiNum) {
						isTaxiNum = true;

						try {
							rs = dbconn.queryExecute(query.find_TaxiNum(data, "taxi"));

							while (rs.next()) {

								if (rs.getInt(1) == 0) {
									rs1 = dbconn.queryExecute(query.find_MaxId("taxi_id", "taxi"));

									while (rs1.next()) {
										int taxiId = rs1.getInt(1) + 1;
										// System.out.println("Insert record in
										// taxi table");

										dbconn.queryUpdate(query.insert_Taxi(data, "taxi", taxiId));
									}

									rs1 = dbconn.queryExecute(query.get_seqNum("taxi"));

									while (rs1.next()) {

										mpId = rs1.getInt(1);
									}
								} else {

								}
							}
						} catch (Exception e) {
							System.out.println("Exception");
						}
					}

					if (tp_cnt < cnt) {
						tp_cnt++;

						tokenized.tokenize(data);

						if (tp_cnt == 1) {
							start_pt = tokenized.getLatitude() + " " + tokenized.getLongitude();

							start_time = tokenized.getDate_str();
						}

						tpArr += "( tpoint(st_point(" + tokenized.getLatitude() + ", " + tokenized.getLongitude()
								+ "), timestamp '" + tokenized.getDate_str() + "') )";

						ptArr += tokenized.getLatitude() + " " + tokenized.getLongitude();

						if (tp_cnt < cnt) {

							tpArr += ",";

							ptArr += ",";
						}

						end_time = tokenized.getDate_str();

						print_cnt++;
						// System.out.println(print_cnt);
					} else if (tp_cnt >= cnt) {

						segId++;

						next_segId = segId + 1;

						before_segId = segId - 1;

						ptArr += ", " + start_pt;

						dbconn.queryUpdate(query.insert_traj(mpId, segId, next_segId, before_segId, tp_cnt,
								query.make_polygon(ptArr), start_time, end_time, query.make_tpseg(tpArr)));

						tp_cnt = 1;

						tokenized.tokenize(data);

						start_pt = tokenized.getLatitude() + " " + tokenized.getLongitude();

						start_time = tokenized.getDate_str();

						tpArr = "( tpoint(st_point(" + tokenized.getLatitude() + ", " + tokenized.getLongitude()
								+ "), timestamp '" + tokenized.getDate_str() + "') )";

						ptArr = tokenized.getLatitude() + " " + tokenized.getLongitude();

						if (tp_cnt < cnt) {

							tpArr += ",";
							ptArr += ",";
						}
						// System.out.println(print_cnt);
						print_cnt++;

					}
				}

				if (tp_cnt < cnt) {
					segId++;

					next_segId = segId + 1;

					before_segId = segId - 1;

					ptArr += start_pt;

					if (tpArr.length() > 0) {
						tpArr = tpArr.substring(0, tpArr.lastIndexOf(','));

						end_time = tokenized.getDate_str();

						dbconn.queryUpdate(query.insert_traj(mpId, segId, next_segId, before_segId, tp_cnt,
								query.make_polygon(ptArr), start_time, end_time, query.make_tpseg(tpArr)));
					}
					// System.out.println(query.insert_traj(mpId, segId,
					// next_segId,
					// before_segId, tp_cnt, query.make_polygon(ptArr),
					// tokenized.getDate_str(), tokenized.getDate_str(),
					// query.make_tpseg(tpArr)));
				}
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		long end = System.currentTimeMillis();

		System.out.println("Total Time : " + (end - start) / 1000.0);
	}

	public void data_insert(int cnt, String filePath) {

		int segId = 0, next_segId = 0, before_segId = 0, mpId = 0;

		String start_time = "", end_time = "";

		Make_Query query = new Make_Query();

		try {
			in = new BufferedReader(new FileReader(filePath));
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		int print_cnt = 0;

		String data;

		boolean isTaxiNum = false;

		long start = System.currentTimeMillis();

		try {

			int tp_cnt = 0;

			String ptArr = "", tpArr = "", start_pt = "";

			Tokenize_data tokenized = new Tokenize_data();

			while ((data = in.readLine()) != null) {

				if (!isTaxiNum) {
					isTaxiNum = true;

					try {
						rs = dbconn.queryExecute(query.find_TaxiNum(data, "taxi"));

						while (rs.next()) {

							if (rs.getInt(1) == 0) {
								rs1 = dbconn.queryExecute(query.find_MaxId("taxi_id", "taxi"));

								while (rs1.next()) {
									int taxiId = rs1.getInt(1) + 1;
									System.out.println("Insert record in taxi table");

									dbconn.queryUpdate(query.insert_Taxi(data, "taxi", taxiId));
								}

								rs1 = dbconn.queryExecute(query.get_seqNum("taxi"));

								while (rs1.next()) {

									mpId = rs1.getInt(1);
								}
							} else {

							}
						}
					} catch (Exception e) {
						System.out.println("Exception");
					}
				}

				if (tp_cnt < cnt) {
					tp_cnt++;

					tokenized.tokenize(data);

					if (tp_cnt == 1) {
						start_pt = tokenized.getLatitude() + " " + tokenized.getLongitude();

						start_time = tokenized.getDate_str();
					}

					tpArr += "( tpoint(st_point(" + tokenized.getLatitude() + ", " + tokenized.getLongitude()
							+ "), timestamp '" + tokenized.getDate_str() + "') )";

					ptArr += tokenized.getLatitude() + " " + tokenized.getLongitude();

					if (tp_cnt < cnt) {

						tpArr += ",";

						ptArr += ",";
					}

					end_time = tokenized.getDate_str();

					print_cnt++;
					System.out.println(print_cnt);
				} else if (tp_cnt >= cnt) {

					segId++;

					next_segId = segId + 1;

					before_segId = segId - 1;

					ptArr += ", " + start_pt;

					dbconn.queryUpdate(query.insert_traj(mpId, segId, next_segId, before_segId, tp_cnt,
							query.make_polygon(ptArr), start_time, end_time, query.make_tpseg(tpArr)));

					tp_cnt = 1;

					tokenized.tokenize(data);

					start_pt = tokenized.getLatitude() + " " + tokenized.getLongitude();

					start_time = tokenized.getDate_str();

					tpArr = "( tpoint(st_point(" + tokenized.getLatitude() + ", " + tokenized.getLongitude()
							+ "), timestamp '" + tokenized.getDate_str() + "') )";

					ptArr = tokenized.getLatitude() + " " + tokenized.getLongitude();

					if (tp_cnt < cnt) {

						tpArr += ",";
						ptArr += ",";
					}

					System.out.println(print_cnt);
					print_cnt++;

				}
			}

			if (tp_cnt < cnt) {
				segId++;

				next_segId = segId + 1;

				before_segId = segId - 1;

				ptArr += start_pt;

				tpArr = tpArr.substring(0, tpArr.lastIndexOf(','));

				end_time = tokenized.getDate_str();

				dbconn.queryUpdate(query.insert_traj(mpId, segId, next_segId, before_segId, tp_cnt,
						query.make_polygon(ptArr), start_time, end_time, query.make_tpseg(tpArr)));

			}
			System.out.println(query.insert_traj(mpId, segId, next_segId, before_segId, tp_cnt,
					query.make_polygon(ptArr), start_time, end_time, query.make_tpseg(tpArr)));
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		long end = System.currentTimeMillis();

		System.out.println("Total Time : " + (end - start) / 1000.0);
	}

	public void dbcon() {
		if (dbconn.dbconnector()) {
			System.out.println("DB Connect Success!");
		} else {
			System.out.println("DB Connect Fail!");
		}
	}

	public void dbclose() {
		System.out.println("DB closed");
		dbconn.closeDB();
	}

	public static void main(String[] args) throws IOException, SQLException {

		Main main = new Main();

		main.dbcon();

//		String filePath = "D:\\2016\\00012\\9720.txt";
		// 占쏙옙占쏙옙占쏙옙 占쏙옙占쏙옙
		// main.data_insert(150, filePath);

		main.data_insert(150);
		main.dbclose();
	}
}
