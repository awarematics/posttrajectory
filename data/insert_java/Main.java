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

		File[] pathArr = f.listFiles();

		File tmp_file;
		String dir_name = "";

		for (int i = 0; i < pathArr.length; i++) {

			if (pathArr[i].getAbsolutePath().length() != 5) {

				dir_name = pathArr[i].getName();

				for (; dir_name.length() < 5;) {
					dir_name = "0" + dir_name;
				}
				tmp_file = new File(pathArr[i].getAbsolutePath());
				tmp_file.renameTo(new File(pathArr[i].getParent() + "/"
						+ dir_name));

			} else {
				tmp_file = new File(pathArr[i].getAbsolutePath());
			}
		}

		Arrays.sort(pathArr);

		int total = 0;

		for (int i = 0; i < pathArr.length; i++) {
			// System.out.println(pathArr[i].getAbsolutePath());
			total += pathArr[i].list().length;
		}
		// System.out.println(total);

		File[] result = new File[total];
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

	public void data_insert() {

		Make_Query query = new Make_Query();

		String path;

		path = "/root/Data Set/T-Drive/";

		file_name = this.get_fileArr(path);

		// for (int t = 0; t < file_name.length; t++) {

		try {
			in = new BufferedReader(new FileReader(file_name[0]));
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		String data;

		boolean isTaxiNum = false;

		long start = System.currentTimeMillis();

		try {
			String total_query = "";

			FileWriter fw = null;

			fw = new FileWriter("/root/Data Set/tmp.txt", true);

			while ((data = in.readLine()) != null) {

				if (!isTaxiNum) {
					isTaxiNum = true;

					try {
						rs = dbconn.queryExecute(query.find_TaxiNum(data,
								"taxi"));

						while (rs.next()) {

							if (rs.getInt(1) == 0) {
								rs1 = dbconn.queryExecute(query.find_MaxId(
										"taxi_id", "taxi"));

								while (rs1.next()) {
									int idx = rs1.getInt(1);
									System.out.println("taxi ���̺? �����մϴ�");
									dbconn.queryUpdate(query.insert_Taxi(data,
											"taxi", ++idx));
								}

							}
						}
					} catch (Exception e) {
						System.out.println("���� ����");
					}
				}

				total_query = query.make_appendquery(data, "taxi", "traj");
				// System.out.println(total_query);

				fw.write(total_query + "\r\n");

				// System.out.println(query.make_appendquery(data, "taxi",
				// "traj"));
			}

			// dbconn.queryUpdate(total_query);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		long end = System.currentTimeMillis();

		System.out.println("실행 시간 : " + (end - start) / 1000.0);
		// }
	}

	public void dbcon() {
		if (dbconn.dbconnector()) {
			System.out.println("���� ����");
		} else {
			System.out.println("����");
		}
	}

	public void dbclose() {
		System.out.println("DB ���� ����");
		dbconn.closeDB();
	}

	public static void main(String[] args) throws IOException, SQLException {

		Main main = new Main();

		main.dbcon();

		// ������ ����
		main.data_insert();

		main.dbclose();
	}
}
