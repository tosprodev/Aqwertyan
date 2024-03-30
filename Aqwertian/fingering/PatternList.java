package Aqwertian.fingering;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.Reader;
import java.util.ArrayList;
import java.util.List;
import Aqwertian.fingering.util.StringTokenizer;

/**
 * A Pattern that can be used by specific algorithms to enhance fingering.
 * The Pattern file must have the following format:
 * One line per pattern.
 * Each note in the pattern (MIDI note number), space delimited,
 * followed by the qwerty key for those notes, also space delimited.
 * For example:
 * 64 52 F K
 * There must be as many keys in each pattern as there are notes.
 * If there are any patterns that are subsets of other patterns, the
 * LONGEST pattern must come first in the file.
 * 
 * Note: This was experimental and doesn't seem to be used. The patterns
 * file is specific to the file being translated, limiting its usefulness.
 * It is currently used only by the Usage algorithm and only if the patterns
 * file exists.
 */
public class PatternList {
	private final List<Pattern> _patterns;

	public static class Pattern {
		public int id;
		public int[] notes;
		public char[] qwertys;
		public int frequency;
	}
	
	public PatternList() {
		_patterns = new ArrayList<Pattern>();
	}

	public PatternList(Reader in) throws IOException {
		_patterns = extractPatterns(new BufferedReader(in));
	}

	private List<Pattern> extractPatterns(BufferedReader in) throws IOException {
		List<Pattern> patterns = new ArrayList<Pattern>();
		String line;
		int lineCount = 0;
		while ((line = in.readLine()) != null) {
			lineCount++;
			StringTokenizer tok = new StringTokenizer(line);
			int count = 0;
			while (tok.hasMoreTokens()) {
				tok.nextToken();
				count++;
			}
			if (count % 2 != 0)
				throw new IllegalArgumentException("File has illegal format. Line: " + lineCount);
			count /= 2;
			tok = new StringTokenizer(line);
			Pattern p = new Pattern();
			p.id = lineCount;
			p.notes = new int[count];
			p.qwertys = new char[count];
			int n = 0;
			while (tok.hasMoreTokens()) {
				String item = tok.nextToken();
				if (n < count)
					p.notes[n] = Integer.parseInt(item);
				else
					p.qwertys[n - count] = item.charAt(0);
				n++;
			}
			patterns.add(p);
		}
		return patterns;
	}

	public static interface NoteFinder {
		int getNote(int index);
	}

	public Pattern matchPattern(NoteFinder f) {
		for (Pattern p : _patterns) {
			boolean found = true;
			for (int i = 0; i < p.notes.length; i++) {
				if (p.notes[i] != f.getNote(i)) {
					found = false;
					break;
				}
			}
			if (found)
				return p;
		}
		return null;
	}

	@Override
	public String toString() {
		StringBuffer buff = new StringBuffer("Patterns (notes; keys [usage count]):\n");
		for (Pattern p : _patterns) {
			buff.append("   ").append(p.id).append("-");
			for (int i = 0; i < p.notes.length; i++)
				buff.append(' ').append(p.notes[i]);
			buff.append(';');
			for (int i = 0; i < p.notes.length; i++)
				buff.append(' ').append(p.qwertys[i]);
			buff.append(" [").append(p.frequency).append(']').append('\n');
		}
		return buff.toString();
	}
}
