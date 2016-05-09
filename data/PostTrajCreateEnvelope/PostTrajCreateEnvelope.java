
import java.io.IOException;
import java.io.InputStream;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Properties;
import java.util.Random;

import com.vividsolutions.jts.geom.Envelope;

public class PostTrajCreateEnvelope {
	
	public Envelope getQueryEnvelope(Envelope envelope, double distance) {
		this.distance = distance;
		Random random = new Random();
		double query_range_x = (envelope.getMaxX() - envelope.getMinX()) * distance;
		double query_range_y = (envelope.getMaxY() - envelope.getMinY()) * distance;
		double pos = random.nextDouble();
		posx = envelope.getMaxX() + (envelope.getMinX() - envelope.getMaxX()) * pos;
		posy = envelope.getMaxY() + (envelope.getMinY() - envelope.getMaxY()) * pos;

		double minx = posx - (query_range_x / 2);

		double maxx = posx + (query_range_x / 2);

		double miny = posy - (query_range_y / 2);

		double maxy = posy + (query_range_y / 2);

		if (minx < envelope.getMinX()) {
			minx = envelope.getMinX();
			maxx = envelope.getMinX() + posx;
		}

		if (maxx > envelope.getMaxX()) {
			minx = envelope.getMaxX() - posx;
			maxx = envelope.getMaxX();
		}

		if (miny < envelope.getMinY()) {
			miny = envelope.getMinY();
			maxy = envelope.getMinY() + posy;
		}
		if (maxy > envelope.getMaxY()) {
			miny = envelope.getMaxY() - posy;
			maxy = envelope.getMaxY();
		}
		Envelope queryEnvelope = new Envelope(minx, maxx, miny, maxy);

		return queryEnvelope;
	}
	
	public void testSpatialRangeQuery() throws Exception {
		
		Envelope mbr = null;
		Envelope queryEnvelope = null;

		double[] ranges = {0.01, 0.05, 0.07, 0.87, 0.1, 0.16, 0.23, 0.275, 0.32}; // 0.1%. 0.25%, 0.5%, 0.75%, 1%, 2.5%, 5% 7.5% 10%
		String[] ranges_string = {"0.1%", "0.25%", "0.5%", "0.7%", "1%", "2.5%", "5%", "7.5%", "10%"};

		for(int i=0; i<ranges.length; i++){
		
				queryEnvelope = this.getQueryEnvelope(mbr, ranges[i]);
						
				System.out.println("result size : " + result.size());
				// minx, miny, maxx, maxy, range, result size, query-start, query-end, execution time, paritition
				System.out.println(queryEnvelope.getMinX() + "\t");
				System.out.println(queryEnvelope.getMinY() + "\t");
				System.out.println(queryEnvelope.getMaxX() + "\t");
				System.out.println(queryEnvelope.getMaxY() + "\t");
				System.out.println(ranges_string[i] + "\t");				
			}
		}
	}

	public static void main(String[] args) {
		PostTrajCreateEnvelope main = new PostTrajCreateEnvelope();		
		
	}
}
