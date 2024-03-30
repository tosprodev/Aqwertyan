//  Copyright (c) 2001 Aqwertian, Inc. All rights reserved.
package Aqwertian.fingering;

import java.util.Collection;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.Map;
import java.util.Random;
import java.util.TreeMap;

import Aqwertian.fingering.MusicFile.Note;

/**
 * Maps {@link Note}s to keys on a qwerty keyboard.
 * 
 * @author Robert Gardner (robert@rdgardnerfamily.com)
 */
public class QwertyMapper {
	/** The mapping algorithm to use. */
	private MapAlgorithm _algo;
	/**
	 * A histogram of the notes and fingerings chosen, which can be used to
	 * even out the fingering assignments. It can be reported for evaluation purposes.
	 */
	private final Map<String, Integer> _noteHist = new TreeMap<String, Integer>();
	public final Random rand;

	/** The number of notes over which repetitions result in reusing the same  key. */
	private static final int USAGE_LIMIT = 5;
    
	/**
	 * Indicates which Finger corresponds to a qwerty key.
	 * Each string is L/R (left or right), Finger # (1-4), Row (1-4)
	 * The array starts with 'space' and increases in ASCII value.
	 */
	public static final String[] FINGER = {
		// space - /
		"R00", "", "", "", "", "", "", "", "", "", "", "", "R21", "", "R31", "R41",
		// 0 - 9
		"R44", "L44", "L34", "L24", "L14", "L14", "R14", "R14", "R24", "R34",
		// : - @
		"", "R42", "", "", "", "", "",
		// A - M
		"L42", "L11", "L21", "L22", "L23", "L12", "L12", "R12", "R23", "R12", "R22", "R32", "R11",
		// N - Z
		"R11", "R33", "R43", "L43", "L13", "L32", "L13", "R13", "L11", "L33", "L31", "R13", "L41" };
	public static final char FINGER_START = ' ';

	public enum Algorithm {
		RANDOM,
		ROUND_ROBIN,
		USAGE,
	}
	
	public enum LevelOfDifficulty {
		BEGINNER,
		INTERMEDIATE,
		ADVANCED,
		EXPERT,
	}

	public QwertyMapper(Algorithm algorithm, LevelOfDifficulty level, Random rand) {
		this.rand = rand;
		switch (algorithm) {
			case RANDOM:
				_algo = new RandomAlgorithm(this);
				break;
			case ROUND_ROBIN:
				_algo = new RoundRobinAlgorithm(this);
				break;
			case USAGE:
				_algo = new UsageAlgorithm(this, level);
				break;
			default:
				throw new IllegalArgumentException("Unrecognized algorithm: " + algorithm);
		}
	}

	public QwertyMapper(Algorithm algorithm, LevelOfDifficulty level) {
		this(algorithm, level, new Random());
	}

	public String getInfo() {
		return _algo.getInfo();
	}

	/**
	 * Maps {@link Note}s by assigning the 'qwerty' and 'reason' fields
	 * of each note in the list. Notes are not added or removed from the collection,
	 * but each note in the collection is modified.
	 */
	public void map(Collection<Note> notes, PatternList patterns) {
		for (Note n : notes) {
			addToHistogram(_noteHist, n.getNoteValue());
		}
		_algo.map(notes, patterns, _noteHist);
	}

	/** Determines the hand (left 'L' or right 'R') that normally presses a key. */
	public static char getHand(int qwerty) {
		return FINGER[qwerty - FINGER_START].charAt(0);
	}

	/** Determines the finger (1-4) that normally presses a key. */
	public static String getFinger(int qwerty) {
		return FINGER[qwerty - FINGER_START].substring(0, 2);
	}

	/** Determines the row on the qwerty keyboard (1-4) of a key. */
	public static int getRow(int qwerty) {
		return FINGER[qwerty - FINGER_START].charAt(2) - '0';
	}

	/** Returns the key on a qwerty keyboard of a finger and row on the keyboard. */
	public static char getQwerty(String finger, int row) {
		String f = finger + row;
		for (int i = 0; i < FINGER.length; i++)
			if (FINGER[i].equals(f))
				return (char) (i + FINGER_START);
		return 0;
	}

	/** Returns the key on the keyboard corresponding to an index in the FINGER array. */
	static char getKey(int index) {
		return (char) (FINGER_START + index);
	}

	/** Returns the index with the FINGER array of a key on the keyboard. */
	static int getIndex(char key) {
		return (key - FINGER_START);
	}

	/**
	 * The history of key used in the notes. Useful for evening out finger selection.
	 */
	static class KeyHistory {
		/** Recently mapped notes. */
		private final LinkedList<Note> _mapped;
		/** Notes that are currently "playing". */
		private final LinkedList<Note> _playing;

		private KeyHistory() {
			_mapped = new LinkedList<Note>();
			_playing = new LinkedList<Note>();
		}

		public void addNote(Note n) {
			_mapped.addFirst(n);
			if (_mapped.size() > USAGE_LIMIT)
				_mapped.removeLast();
			// Now remove any notes that have stopped playing
			int currTime = n.time;
			for (Iterator<Note> it = _playing.iterator(); it.hasNext();) {
				MusicFile.Note note = it.next();
				int noteOffTime = note.time + note.duration;
				if (noteOffTime <= currTime)
					it.remove();
			}
			_playing.addLast(n);
		}

		public MusicFile.Note getPrevious() {
			if (_mapped.size() == 0)
				return null;
			return _mapped.get(0);
		}

		public MusicFile.Note findMappedNote(MusicFile.Note n) {
			for (Note used : _mapped) {
				if (used.note == n.note)
					return used;
			}
			return null;
		}

		public boolean isPlaying(MusicFile.Note note) {
			return _playing.contains(note);
		}

		public boolean isFingerDown(String nextFinger) {
			for (Note n : _playing) {
				String finger = getFinger(n.qwerty);
				if (nextFinger.equals(finger))
					return true;
			}
			return false;
		}
	}
	
	KeyHistory createKeyHistory() {
		return new KeyHistory();
	}

	boolean ruleFails(KeyHistory history, MusicFile.Note currNote, char key) {
		MusicFile.Note prevNote = history.getPrevious();
		if (prevNote == null)
			return false;
		if (prevNote.qwerty == key && prevNote.note == currNote.note)
			return false;
		String prevFinger = getFinger(prevNote.qwerty);
		String nextFinger = getFinger(key);
		if (isImpossibleFinger(prevFinger, nextFinger))
			return true;
		if (history.isFingerDown(nextFinger))
			return true;
		return false;
	}

	private boolean isImpossibleFinger(String prevFinger, String nextFinger) {
		if (prevFinger.charAt(0) != nextFinger.charAt(0))
			return false;
		if (prevFinger.charAt(1) == nextFinger.charAt(1))
			return true;
		switch (prevFinger.charAt(1)) {
			case '1' :
				return (nextFinger.charAt(1) == '2');
			case '2' :
				return (nextFinger.charAt(1) == '1' || nextFinger.charAt(1) == '3');
			case '3' :
				return (nextFinger.charAt(1) == '2' || nextFinger.charAt(1) == '4');
			case '4' :
				return (nextFinger.charAt(1) == '3');
		}
		return false;
	}

	public String toString(MusicFile.Note n) {
		String s = n.toString();
		s += "(" + n.note + ")";
		s += " - " + n.qwerty + "/" + getFinger(n.qwerty) + " " + getRow(n.qwerty);
		if (n.reason != null)
			s += ". Reason: " + n.reason;
		return s;
	}

	private void addToHistogram(Map<String, Integer> hist, String key) {
		int count = 0;
		if (hist.containsKey(key))
			count = hist.get(key);
		count++;
		hist.put(key, count);
	}

	public void printStatistics(Collection<Note> notes) {
		printHistogram(_noteHist, "Histogram of Notes");
		System.out.println();
		Map<String, Integer> qwertyHist = new TreeMap<String, Integer>();
		for (Note n : notes) {
			addToHistogram(qwertyHist, String.valueOf(n.qwerty));
		}
		printHistogram(qwertyHist, "Histogram of Key Usage");
		System.out.println();
		qwertyHist = new TreeMap<String, Integer>();
		for (Note n : notes) {
			addToHistogram(qwertyHist, getFinger(n.qwerty));
		}
		printHistogram(qwertyHist, "Histogram of Finger Usage");
		System.out.println();
		qwertyHist = new TreeMap<String, Integer>();
		for (Note n : notes) {
			addToHistogram(qwertyHist, String.valueOf(getRow(n.qwerty)));
		}
		printHistogram(qwertyHist, "Histogram of Row Usage");
	}

	private void printHistogram(Map<String, Integer> hist, String title) {
		System.out.println(title);
		int total = 0;
		for (String key : hist.keySet()) {
			int count = hist.get(key);
			total += count;
			System.out.println(key + ": " + count);
		}
		System.out.println(hist.size() + " bins, " + total + " values.");
	}
}
