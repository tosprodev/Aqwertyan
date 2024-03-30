//  Copyright (c) 2001 Aqwertian, Inc. All rights reserved.
package Aqwertian.fingering;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import Aqwertian.fingering.util.StringTokenizer;

import Aqwertian.fingering.MusicFile.Note;
import Aqwertian.fingering.QwertyMapper.LevelOfDifficulty;

/**
 * An algorithm that assigns fingers depending on their usage.
 * This algorithm attempts to spread finger selection somewhat evenly among
 * the fingers. Properly assigns chords, making certain to avoid impossible
 * fingering.
 * 
 * @author Robert Gardner (robert@rdgardnerfamily.com)
 */
public class UsageAlgorithm implements MapAlgorithm {
	private final QwertyMapper _mapper;
	private final int[] _frequency;

	/**
	 * Constructs the algorithm.
	 * 
	 * @param m the mapper making use of this algorithm
	 * @param level the level of difficulty; more difficult levels spread
	 *     fingers around more
	 */
	public UsageAlgorithm(QwertyMapper m, LevelOfDifficulty level) {
		_mapper = m;
		System.out.println("Using level: " + level);
		switch (level) {
			case BEGINNER: _frequency = FREQUENCY_BEGINNER; break;
			case INTERMEDIATE: _frequency = FREQUENCY_INTERMEDIATE; break;
			case ADVANCED: _frequency = FREQUENCY_ADVANCED; break;
			case EXPERT: _frequency = FREQUENCY_EXPERT; break;
			default: _frequency = FREQUENCY_EXPERT; break;
		}
	}

	/** Relative frequency of each of the keys. Scale is irrelevant. */
	public static final int[] FREQUENCY_INTERMEDIATE = {
		// space - /
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 878, 0, 752, 0,
		// 0 - 9
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		// : - @
		0, 9081, 0, 0, 0, 0, 0,
		// A - M
		8255, 439, 815, 9917, 2268, 5340, 5340, 5340, 2442, 5340, 10680, 9154, 439,
		// N - Z
		439, 2093, 1919, 1744, 1221, 9154, 1221, 1221, 439, 2093, 752, 1221, 0 };

	public static final int[] FREQUENCY_BEGINNER = {
		// space - /
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		// 0 - 9
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		// : - @
		0, 11000, 0, 0, 0, 0, 0,
		// A - M
		10000, 0, 0, 13000, 0, 7000, 7000, 7000, 0, 7000, 14000, 12000, 0,
		// N - Z
		0, 0, 0, 0, 0, 12000, 0, 0, 0, 0, 0, 0, 0 };

	public static final int[] FREQUENCY_ADVANCED = {
		// space - /
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 877, 0, 985, 985,
		// 0 - 9
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		// : - @
		0, 8656, 0, 0, 0, 0, 0,
		// A - M
		7856, 575, 1068, 9190, 2590, 4878, 4878, 4878, 2779, 4878, 9909, 8472, 575,
		// N - Z
		575, 2390, 2191, 1992, 1394, 8472, 1390, 1394, 575, 2390, 985, 1394, 821 };

	public static final int[] FREQUENCY_EXPERT = {
		// space - /
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 788, 0, 939, 861,
		// 0 - 9
		514, 467, 561, 607, 327, 327, 327, 327, 654, 561,
		// : - @
		0, 8264, 0, 0, 0, 0, 0,
		// A - M
		7501, 548, 1018, 8773, 2469, 4663, 4663, 4663, 2659, 4663, 9458, 8088, 548,
		// N - Z
		548, 2279, 2079, 1899, 1329, 8088, 1329, 1329, 548, 2279, 939, 1329, 783 };

	private static int count(int[] values) {
		int count = 0;
		for (int i = 0; i < values.length; i++) {
			count += values[i];
		}
		return count;
	}

	public String getInfo() {
		return "Key assignment based on key usage.";
	}

	public void map(Collection<Note> nts, PatternList patterns, Map<String, Integer> notesHistogram) {
		MusicFile.Note[] notes = nts.toArray(new MusicFile.Note[nts.size()]);
		// Prepare the expected frequencies by scaling the FREQUENCY array.
		int[] freq = new int[_frequency.length];
		int[] used = new int[_frequency.length];
		int freqCount = count(_frequency);
		for (int i = 0; i < freq.length; i++) {
			if (_frequency[i] != 0) {
				// Make sure it rounds up
				freq[i] = (int) ((double) (freqCount + _frequency[i] - 1) / _frequency[i]);
			}
		}

		QwertyMapper.KeyHistory history = _mapper.createKeyHistory();
		for (int count = 0; count < notes.length; count++) {
			MusicFile.Note n = notes[count];
			if (n.note == 0) {
				n.qwerty = ' ';
				continue;
			}
			int skip = matchPattern(notes, patterns, count);
			if (skip > 0) {
				count += skip - 1; // -1 since for loop will increment it
				continue;
			}
			skip = matchChord(notes, count);
			if (skip > 0) {
				count += skip - 1; // -1 since for loop will increment it
				continue;
			}
			MusicFile.Note historyNote = history.findMappedNote(n);
			int index;
			if (historyNote != null && !_mapper.ruleFails(history, n, historyNote.qwerty)) {
				index = _mapper.getIndex(historyNote.qwerty);
				n.reason = "Previously mapped.";
			} else {
				NextKey k = calcNextKey(history, n, freq, used);
				index = k.index;
				n.reason = k.reason;
			}
			used[index] = count;
			char key = _mapper.getKey(index);
			n.qwerty = key;
			history.addNote(n);
//			System.out.println(count + ":" + n);
		}
	}

	private static class NextKey {
		public int index;
		public String reason;
	}
	private List<Integer> _firstKeys;
	/** Finds the note with lowest freq + used count and assign it. */
	private NextKey calcNextKey(QwertyMapper.KeyHistory history, MusicFile.Note currNote, int[] freq, int[] used) {
		NextKey ret = new NextKey();
		ret.index = -1;
		if (_firstKeys == null)
			_firstKeys = getFirstKeys();
		if (_firstKeys.size() > 0) {
			for (int i = 0; i < _firstKeys.size(); i++) {
				ret.index = _firstKeys.get(i).intValue();
				if (!_mapper.ruleFails(history, currNote, _mapper.getKey(ret.index))) {
					_firstKeys.remove(i);
					ret.reason = "From first keys list.";
					return ret;
				}
			}
		}
		boolean[] tried = new boolean[freq.length];
		do {
			int min = Integer.MAX_VALUE;
			ret.index = -1;
			for (int i = 0; i < freq.length; i++) {
				if (freq[i] == 0 || tried[i])
					continue;
				int usage = freq[i] + used[i];
				if (usage < min) {
					min = usage;
					ret.index = i;
					ret.reason = "Lowest frequency (" + freq[i] + ") plus use count (" + used[i] + ").";
				}
			}
			if (ret.index < 0) {
				ret.index = _mapper.getIndex('A');
				ret.reason = "Could not find an unused finger.";
				break;
			}
			tried[ret.index] = true;
		} while (_mapper.ruleFails(history, currNote, _mapper.getKey(ret.index)));
		return ret;
	}

	private List<Integer> getFirstKeys() {
		int count = 0;
		for (int i = 0; i < _frequency.length; i++)
			if (_frequency[i] != 0)
				count++;
		int[] keys = new int[count];
		for (int i = 0; i < _frequency.length; i++) {
			if (_frequency[i] != 0) {
				int index;
				do {
					index = _mapper.rand.nextInt(keys.length);
				} while (keys[index] != 0);
				keys[index] = i + 1;
			}
		}
		List<Integer> keyList = new ArrayList<Integer>();
		for (int i = 0; i < keys.length; i++)
			keyList.add(keys[i] - 1);
		return keyList;
	}

	private int matchPattern(final MusicFile.Note[] notes, PatternList patterns, final int count) {
		int skip = 0;
		PatternList.Pattern p = patterns.matchPattern(new PatternList.NoteFinder() {
			public int getNote(int index) {
				if (count + index >= notes.length)
					return -1;
                MusicFile.Note n = notes[count+index];
				return n.note;
			}
		});
		if (p != null) {
			p.frequency++;
			skip = p.qwertys.length;
			for (int i = 0; i < skip; i++) {
				MusicFile.Note n = notes[count + i];
				n.qwerty = p.qwertys[i];
				n.reason = "Pattern " + p.id + "." + (i+1);
			}
		}
		return skip;
	}

	private int matchChord(MusicFile.Note[] notes, int count) {
		int skip = 0;
		MusicFile.Note start = notes[count];
		List<Note> chord = new ArrayList<Note>();
		chord.add(start);
		for (int i = count + 1; i < notes.length; i++) {
			MusicFile.Note n = notes[i];
			if (start.time == n.time)
				chord.add(n);
		}
		if (chord.size() >= 3 && chord.size() <= 4)
			skip = processChord(chord);
		return skip;
	}
	
	private static class ChordFinger {
		public int maxMidi;
		public char[] fingers;
		public ChordFinger(int max, String f) {
			maxMidi = max;
			fingers = new char[4];
			fingers[0] = f.charAt(0);
			fingers[1] = f.charAt(1);
			fingers[2] = f.charAt(2);
			fingers[3] = f.charAt(3);
		}
	}
	private static ChordFinger[] _chording = {
		new ChordFinger(19, "VCXZ"), new ChordFinger(31, "FDSA"),
		new ChordFinger(43, "REWQ"), new ChordFinger(55, "4321"),
		new ChordFinger(67, "M,./"), new ChordFinger(79, "JKL;"),
		new ChordFinger(91, "UIOP"), new ChordFinger(999, "7890")
	};
	
	private int processChord(List<Note> chord) {
		Collections.sort(chord, new Comparator<Note>() {
			public int compare(Note n1, Note n2) {
				return n1.note - n2.note;
			}
		});
		Iterator<Note> it = chord.iterator();
		Note start = it.next();
		ChordFinger finger = findChordFingering(start.note);
		start.qwerty = finger.fingers[0];
		start.reason = "Chord - Base note.";
		int index = 1;
		while (it.hasNext() && index < finger.fingers.length) {
			MusicFile.Note n = it.next();
			n.qwerty = finger.fingers[index];
			n.reason = "Chord - continuation.";
			index++;
		}
		return index;
	}

	private ChordFinger findChordFingering(int note) {
		for (int i = 0; i < _chording.length; i++) {
			if (note <= _chording[i].maxMidi)
				return _chording[i];
		}
		return null;
	}
}
