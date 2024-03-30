package Aqwertian.fingering;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;
import Aqwertian.fingering.util.StringTokenizer;

/**
 * Reads a Jim Planck ".nts" file and extracts {@link Note}s.
 * Also writes the file to an output stream adding fingering instructions.
 * 
 * @author Robert Gardner (robert@rdgardnerfamily.com)
 */
public class MusNotesFile extends MusicFile {
	private final List<MusElement> _elements = new ArrayList<MusElement>();

	private interface MusElement {
		enum Type {
			PIECE("P"),
			MEASURE("M"),
			NOTE("N"),
			MARK("MARK");
			
			private final String prefix;
			
			Type(String prefix) {
				this.prefix = prefix;
			}
			
			String getPrefix() {
				return prefix;
			}
			
			static Type fromPrefix(String prefix) {
				for (Type t : Type.values()) {
					if (t.getPrefix().equals(prefix)) {
						return t;
					}
				}
				return null;
			}
		}
		public Type getType();
		public String getLine();
	}

	private static class BasicElement implements MusElement {
		private final Type _type;
		protected List<String> _words;

		public static MusElement create(String line) {
			if (line.startsWith(Type.NOTE.getPrefix()))
				return new MusNote(line);
			if (line.startsWith(Type.PIECE.getPrefix()))
				return new MusPiece(line);
			return new BasicElement(line);
		}

		public BasicElement(String line) {
			_words = parseLine(line);
			_type = Type.fromPrefix(_words.get(0));
			_words.remove(0);
		}

		static List<String> parseLine(String line) {
			List<String> l = new ArrayList<String>();
			StringTokenizer t = new StringTokenizer(line);
			while (t.hasMoreTokens()) {
				String word = t.nextToken();
				l.add(word);
			}
			return l;
		}

		static String composeLine(List<String> words) {
			StringBuffer b = new StringBuffer();
			for (Iterator<String> it = words.iterator(); it.hasNext();) {
				String word = it.next();
				b.append(word);
				if (it.hasNext())
					b.append(' ');
			}
			return b.toString();
		}

		public String getLine() {
			return getType().getPrefix() + " " + composeLine(_words);
		}
		public Type getType() {
			return _type;
		}
	}

	private static class MusPiece extends BasicElement {
		public MusPiece(String line) {
			super(line);
		}
//		public String getName() {
//			return composeLine(_words);
//		}
	}

	private static class MusNote extends Note implements MusElement {
		private final List<String> _words;

		public MusNote(String line) {
			super(0, 0, 0, 0);
			_words = BasicElement.parseLine(line);
			double dtimeon = Double.parseDouble(_words.get(6));
			double dtimeoff = Double.parseDouble(_words.get(7));
			time = (int) (dtimeon * 1000);
			duration = (int) ((dtimeoff - dtimeon) * 1000);
			note = Integer.parseInt(_words.get(3));
			if (!"NO".equals(_words.get(18)) && "-100".equals(_words.get(19)))
				qwerty = _words.get(18).charAt(0);
		}

		public String getLine() {
			adjustWords();
			String s = BasicElement.composeLine(_words);
			if (reason != null && reason.length() != 0)
				s += " # " + reason;
			return s;
		}

		public Type getType() {
			return Type.NOTE;
		}

		public boolean isTieNote() {
			String line = _words.get(4);
			return line.startsWith("TL");
		}

		private void adjustWords() {
			// Make sure the qwerty value gets set back into the words list
			if (qwerty != '\0') {
				_words.set(18, String.valueOf(qwerty));
				_words.set(19, "-100");
				_words.set(20, "0");
				if ("12345QWERTASDFGZXCVB".indexOf(qwerty) >= 0) {
					String l = _words.get(4);
					l = 'L' + l.substring(1);
					_words.set(4, l);
				}
			}
		}
	}

	public MusNotesFile(InputStream in) throws IOException {
		BufferedReader bin = new BufferedReader(new InputStreamReader(in));
		String line;
		while ((line = bin.readLine()) != null) {
			line = line.trim();
			MusElement e = BasicElement.create(line);
			_elements.add(e);
		}
	}
	
	@Override
	public int getChannelCount() {
		return 1;
	}

	@Override
	protected List<Note> extractNotes(Collection<Integer> channels) {
		List<MusNote> musNotes = new ArrayList<MusNote>();
		for (MusElement el : _elements) {
			if (el instanceof MusNote && !((MusNote) el).isTieNote())
				musNotes.add((MusNote) el);
		}
		List<Note> notes = new ArrayList<Note>();
		for (MusNote n : musNotes) {
			notes.add(n);
		}
		return notes;
	}

	@Override
	public void store(OutputStream o) {
		if (_elements.size() == 0)
			return;
		PrintWriter out = new PrintWriter(o);
		for (MusElement el : _elements) {
			out.println(el.getLine());
		}
		out.flush();
	}

	@Override
	public String toString() {
		StringBuffer buff = new StringBuffer();
		for (MusElement el : _elements) {
			buff.append(el.getLine()).append('\n');
		}
		return buff.toString();
	}
}
