package Aqwertian.fingering;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;
import Aqwertian.fingering.util.StringTokenizer;

/**
 * Reads a Jim Planck ".mus" file and extracts {@link Note}s.
 * Also writes the file to an output stream adding fingering instructions.
 * 
 * @author Robert Gardner (robert@rdgardnerfamily.com)
 */
public class MusPlayFile extends MusicFile {
	private static final String INDENT = "  ";
	private String _name;
	private final List<MusPlayNote> _events = new ArrayList<MusPlayNote>();
	private final List<Repeat> _repeats = new ArrayList<Repeat>();

	private static class MusPlayNote extends Note implements Cloneable {
		public static class Duration implements Comparable<Duration>, Cloneable {
			int num;
			int denom = 1;
			int divisor = 1; // "extra" divisor
			private boolean _reducable = true;

			public Duration() {
			}

			public Duration(boolean reducable) {
				_reducable = reducable;
			}

			/**
			 * Adds another duration to this one.
			 * The new numerator is n1 * d2 * e2 + n2 * d1 * e1.
			 * The new denominator is d1 * d2.
			 * The new extra divisor is e1 * e2.
			 * @param toAdd the duration to add.
			 */
			public void add(Duration toAdd) {
				num = num * toAdd.denom * toAdd.divisor + toAdd.num * denom * divisor;
				denom = denom * toAdd.denom;
				divisor = divisor * toAdd.divisor;
				reduce();
			}

			/**
			 * Subtracts another duration from this one.
			 * The new numerator is n1 * d2 * e2 - n2 * d1 * e1.
			 * The new denominator is d1 * d2.
			 * The new extra divisor is e1 * e2.
			 * @param toSub the duration to subtract.
			 */
			public void subtract(Duration toSub) {
				num = num * toSub.denom * toSub.divisor - toSub.num * denom * divisor;
				denom = denom * toSub.denom;
				divisor = divisor * toSub.divisor;
				reduce();
			}

			/**
			 * Compares another duration to this one.
			 * Returns 0 if the two are equal, greater than 0 if this duration is greater
			 * than the other duration, and less than 0 if this duration is less than
			 * the other duration.
			 * Compares n1 * d2 * e2 to n2 * d1 * e1.
			 * @see Comparable#compareTo(Object)
			 */
			public int compareTo(Duration toComp) {
				return num * toComp.denom * toComp.divisor - toComp.num * denom * divisor;
			}

			@Override
			public boolean equals(Object o) {
				if (o instanceof Duration)
					return (compareTo((Duration) o) == 0);
				return false;
			}

			@Override
			protected Object clone() {
				try {
					return super.clone();
				} catch (CloneNotSupportedException e) {
					e.printStackTrace();
					return null;
				}
			}

			private void reduce() {
				if (!_reducable)
					return;
				if (num % divisor == 0) {
					num /= divisor;
					divisor = 1;
				}
				if (num % denom == 0) {
					num /= denom;
					denom = 1;
				}
				while ((num % 2 == 0) && (denom % 2 == 0)) {
					num /= 2;
					denom /= 2;
				}
			}

			@Override
			public String toString() {
				return denom + " " + num + " " + divisor;
			}
		}

		public Duration meter = new Duration(false);
		public String key = "";
		public String tempo = "";
		public int measure = 1;
		public String line = "";
		public int volume = 100;
		public Duration length = new Duration();
		public int sequence;

		public MusPlayNote() {
			super(0, 0, 0, 0);
		}

		public MusPlayNote(MusPlayNote previous) {
			this();
			if (previous != null) {
				meter = (Duration) previous.meter.clone();
				key = previous.key;
				tempo = previous.tempo;
				measure = previous.measure;
				line = previous.line;
				volume = previous.volume;
				sequence = previous.sequence + 1;
			}
		}

		@Override
		protected Object clone() {
			try {
				return super.clone();
			} catch (CloneNotSupportedException e) {
				e.printStackTrace();
				return null;
			}
		}

		@Override
		public String toString() {
			String s = "Measure " + measure + "/" + line + ": ";
			s += note + " " + length.toString();
			return s;
		}

		@Override
		public int compareTo(Note note) {
			MusPlayNote n = (MusPlayNote) note;
			if (measure != n.measure)
				return measure - n.measure;
			int cmp = line.compareTo(n.line);
			if (cmp != 0)
				return cmp;
			return sequence - n.sequence;
		}

		public void addDuration(MusPlayNote toAdd) {
			length.add(toAdd.length);
		}
	}

	private static class Repeat {
		public int start;
		public int end;
		public int repeat_at;
	}

	public MusPlayFile(InputStream in) throws IOException {
		BufferedReader bin = new BufferedReader(new InputStreamReader(in));
		MusPlayNote previous = null;
		MusPlayNote note = null;
		String line;
		while ((line = bin.readLine()) != null) {
			line = line.trim();
			StringTokenizer t = new StringTokenizer(line);
			if (t.hasMoreTokens()) {
				if (note == null)
					note = new MusPlayNote(previous);
				String cmd = t.nextToken();
				boolean isNote = false;
				if ("NAME".equals(cmd))
					_name = line.substring("NAME ".length());
				else if ("MEASURE".equals(cmd))
					note.measure = Integer.parseInt(t.nextToken());
				else if ("METER".equals(cmd)) {
					note.meter.num = Integer.parseInt(t.nextToken());
					note.meter.denom = Integer.parseInt(t.nextToken());
				} else if ("KEY".equals(cmd))
					note.key = t.nextToken();
				else if ("TEMPO".equals(cmd))
					note.tempo = line.substring("TEMPO ".length());
				else if ("LINE".equals(cmd))
					note.line = t.nextToken();
				else if ("REST".equals(cmd)) {
					isNote = true;
					note.note = 0;
					setNoteDuration(note, t);
				} else if ("PHANTOM".equals(cmd)) {
					isNote = true;
					note.note = 0;
					setNoteDuration(note, t);
				} else if ("EXMATCH".equals(cmd))
					note.qwerty = t.nextToken().charAt(0);
				else if ("VOLPERC".equals(cmd))
					note.volume = Integer.parseInt(t.nextToken());
				else if ("CARRY".equals(cmd)) {
					MusPlayNote tmp = new MusPlayNote();
					setNoteDuration(tmp, t);
					previous.addDuration(tmp);
					previous = note;
					note = null;
				} else if ("REPEAT".equals(cmd)) {
					Repeat r = new Repeat();
					r.start = Integer.parseInt(t.nextToken());
					r.end = Integer.parseInt(t.nextToken());
					r.repeat_at = Integer.parseInt(t.nextToken());
					_repeats.add(r);
				} else {
					note.note = getNote(cmd, t);
					if (note.note != 0) {
						isNote = true;
						setNoteDuration(note, t);
					}
				}
				if (isNote) {
					addNote(note);
					previous = note;
					note = null;
				}
			}
		}
		bin.close();
		//		System.out.println(toString());
	}

	private void addNote(MusPlayNote note) {
		_events.add(note);
	}

	private void setNoteDuration(MusPlayNote note, StringTokenizer tok) {
		note.length.denom = Integer.parseInt(tok.nextToken());
		note.length.num = 1;
		note.length.divisor = 1;
		if (tok.hasMoreTokens()) {
			note.length.num = Integer.parseInt(tok.nextToken());
			if (tok.hasMoreTokens())
				note.length.divisor = Integer.parseInt(tok.nextToken());
		}
	}

	private int getNote(String cmd, StringTokenizer tok) {
		int n = calcNote(cmd, "C", 0, tok);
		if (n == 0)
			n = calcNote(cmd, "D", 2, tok);
		if (n == 0)
			n = calcNote(cmd, "E", 4, tok);
		if (n == 0)
			n = calcNote(cmd, "F", 5, tok);
		if (n == 0)
			n = calcNote(cmd, "G", 7, tok);
		if (n == 0)
			n = calcNote(cmd, "A", 9, tok);
		if (n == 0)
			n = calcNote(cmd, "B", 11, tok);
		return n;
	}

	private int calcNote(String cmd, String note, int base, StringTokenizer tok) {
		if (cmd.equals(note))
			return calcOctave(base, Integer.parseInt(tok.nextToken()));
		if (cmd.equals(note + "b"))
			return calcOctave(base - 1, Integer.parseInt(tok.nextToken()));
		if (cmd.equals(note + "bb"))
			return calcOctave(base - 2, Integer.parseInt(tok.nextToken()));
		if (cmd.equals(note + "#"))
			return calcOctave(base + 1, Integer.parseInt(tok.nextToken()));
		if (cmd.equals(note + "x"))
			return calcOctave(base + 2, Integer.parseInt(tok.nextToken()));
		return 0;
	}

	private int calcOctave(int base, int octave) {
		return 60 + octave * 12 + base;
	}

	private static final String[] TONE =
		{ "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B" };

	private String calcMusPlayTone(int note) {
		int base = note % 12;
		return TONE[base];
	}

	private int calcMusPlayOctave(int note) {
		return note / 12 - 5;
	}

	private void resetDuration(MusPlayNote note) {
		note.length.num = 0;
		note.length.denom = note.meter.denom;
		note.length.divisor = 1;
	}

	@Override
	public int getChannelCount() {
		return 1;
	}

	@Override
	protected List<Note> extractNotes(Collection<Integer> channels) {
		Collections.sort(_events);
		processRepeats();
		// TODO calculate times, using measures/lines and tempo
		// Tempo is beat-units beats-per-minute (both integers)
		// TEMPO 8 144 means 144 8th notes per minute
		List<Note> notes = new ArrayList<Note>();
		for (MusPlayNote n : _events) {
			notes.add(n);
		}
		return notes;
	}

	private void processRepeats() {
		List<MusPlayNote> newNotes = new ArrayList<MusPlayNote>();
		for (Repeat r : _repeats) {
			//			System.out.println(
			//				"Processing repeat of measures " + r.start + "-" + r.end + " at " + r.repeat_at);
			for (MusPlayNote n : _events) {
				if (n.measure >= r.start && n.measure <= r.end) {
					MusPlayNote copy = (MusPlayNote) n.clone();
					copy.measure = r.repeat_at + (n.measure - r.start);
					newNotes.add(copy);
				}
			}
		}
		if (newNotes.size() != 0) {
			_events.addAll(newNotes);
			Collections.sort(_events);
		}
	}

	@Override
	public void store(OutputStream o) {
		if (_events.size() == 0)
			return;
		PrintWriter out = new PrintWriter(o);
		MusPlayNote prev = new MusPlayNote();
		out.println("NAME " + _name);
		out.println();
		processMetaInfo(out, prev, _events.get(0));
		resetDuration(prev);
		prev.volume = 100;
		for (MusPlayNote n : _events) {
			processMetaInfo(out, prev, n);
			processMeasure(out, prev, n);
			processLine(out, prev, n);
			processVolume(out, prev, n);
			processNote(out, prev, n);
		}
		out.flush();
	}

	private void processMetaInfo(PrintWriter out, MusPlayNote prev, MusPlayNote n) {
		if (!n.meter.equals(prev.meter) || n.key != prev.key || n.tempo != prev.tempo) {
			out.println("MEASURE " + n.measure);
			out.println(INDENT + "RHNOTE A -4");
			prev.measure = 0;
			prev.line = "";
		}
		if (!n.meter.equals(prev.meter)) {
			out.println(INDENT + "METER " + n.meter.num + " " + n.meter.denom);
			prev.meter.num = n.meter.num;
			prev.meter.denom = n.meter.denom;
		}
		if (n.key != prev.key) {
			out.println(INDENT + "KEY " + n.key);
			prev.key = n.key;
		}
		if (n.tempo != prev.tempo) {
			out.println(INDENT + "TEMPO " + n.tempo);
			prev.tempo = n.tempo;
		}
	}

	private void processMeasure(PrintWriter out, MusPlayNote prev, MusPlayNote n) {
		if (n.measure != prev.measure) {
			prev.measure = n.measure;
			prev.line = "";
			resetDuration(prev);
		}
	}

	private void processLine(PrintWriter out, MusPlayNote prev, MusPlayNote n) {
		if (!n.line.equals(prev.line)) {
			out.println();
			out.println("MEASURE " + n.measure);
			out.println(INDENT + "LINE " + n.line);
			prev.line = n.line;
			resetDuration(prev);
		}
	}

	private void processVolume(PrintWriter out, MusPlayNote prev, MusPlayNote n) {
		if (n.volume != prev.volume) {
			out.println(INDENT + "VOLPERC " + n.volume);
			prev.volume = n.volume;
		}
	}

	private void processNote(PrintWriter out, MusPlayNote prev, MusPlayNote n) {
		prev.addDuration(n);
		if (prev.length.compareTo(prev.meter) > 0) {
			// Went over a measure, split the note.
			// Put carry of prev_duration - tempo into next measure.
			// This note's duration gets reduced by carry duration.
			MusPlayNote.Duration carry = (MusPlayNote.Duration) prev.length.clone();
			carry.subtract(prev.meter);
			MusPlayNote tmp = (MusPlayNote) n.clone();
			tmp.length.subtract(carry);
			outputNote(out, tmp);
			prev.length.subtract(carry);
			prev.measure++;
			outputBeats(out, prev);
			out.println();
			out.println("MEASURE " + prev.measure);
			out.print(INDENT);
			out.print("CARRY");
			outputDuration(out, carry);
			resetDuration(prev);
			prev.length.add(carry);
		} else {
			outputNote(out, n);
		}
		outputBeats(out, prev);
	}

	private void outputNote(PrintWriter out, MusPlayNote n) {
		out.print(INDENT);
		out.print(toMusPlayNote(n.note));
		outputDuration(out, n.length);
		if (n.note != 0) {
			out.println("  EXMATCH " + n.qwerty + " Q");
			if (n.reason != null && n.reason.length() != 0)
				out.println("# " + n.reason);
		}
	}

	private void outputDuration(PrintWriter out, MusPlayNote.Duration d) {
		out.print(" ");
		out.print(d.denom);
		out.print(" ");
		out.print(d.num);
		out.print(" ");
		out.println(d.divisor);
	}

	private void outputBeats(PrintWriter out, MusPlayNote prev) {
//		out.print("# Beats");
//		outputDuration(out, prev.duration);
	}

	private String toMusPlayNote(int note) {
		if (note == 0)
			return "REST";
		return calcMusPlayTone(note) + " " + calcMusPlayOctave(note);
	}

	@Override
	public String toString() {
		StringBuffer buff = new StringBuffer();
		for (MusPlayNote note : _events) {
			buff.append(note.toString()).append('\n');
		}
		return buff.toString();
	}
}
