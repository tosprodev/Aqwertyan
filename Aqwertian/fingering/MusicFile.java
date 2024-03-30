//  Copyright (c) 2001 Aqwertian, Inc. All rights reserved.
package Aqwertian.fingering;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
//import Aqwertian.fingering.util.NumberFormat;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

/**
 * Defines a generic music file that can be converted to {@link Note}s.
 * 
 * @author Robert Gardner (robert@rdgardnerfamily.com)
 */
public abstract class MusicFile {
	/**
	 *  Notes by the tracks that are extracted. This caches each extraction with
	 *  a specific set of tracks for performance reasons. Not sure the caching is really
	 *  necessary, but it's pretty easy. :-)
	 */
    private final Map<Collection<Integer>, List<Note>> _notes = new HashMap<Collection<Integer>, List<Note>>();

    /**
     * A note that can be mapped to a finger using the aqwertian system.
     * During extraction, the "qwerty" and "reason" fields are left blank.
     * Those fields are populated by the {@link QwertyMapper}.
     */
    public static class Note implements Comparable<Note> {
    	/** The channel the note was found on. */
    	public int channel;
    	/** The absolute time the note should play. Units are arbitrary. */
        public int time;
        /** The duration the note should play. Units same as for time. */
        public int duration;
        /** The note being played, from 0 to 127. */
        public int note;
        /** The key on a qwerty keyboard that should be pressed to play this note. */
        public char qwerty;
        /** A reason why the qwerty key was chosen. */
        public String reason;

        Note(int channel, int time, int duration, int note) {
        	this.channel = channel;
            this.time = time;
            this.duration = duration;
            this.note = note;
        }

        private static final String[] NOTES = {
            "C ", "C#", "D ", "D#", "E ", "F ", "F#", "G ", "G#", "A ", "A#", "B "
        };
        
        public String getNoteName() {
            return getNoteName(note);
        }

        public static String getNoteName(int note) {
            return NOTES[note % 12];
        }

        public int getOctave() {
            return getOctave(note);
        }

        public static int getOctave(int note) {
            return note / 12;
        }

        public String getNoteValue() {
            return getNoteValue(note);
        }

        public static String getNoteValue(int note) {
            return getOctave(note) + getNoteName(note);
        }

        // Since the fingering algorithm flattens all channels, they need to be
        // sorted by time to create a sequential piece. This comparison uses duration
        // and note name to further subsort.
		public int compareTo(Note n) {
			int ret = time - n.time;
			if (ret != 0)
				return ret;
			ret = duration - n.duration;
			if (ret != 0)
				return ret;
			return note - n.note;
		}

		@Override
		public String toString() {
           // NumberFormat nf = NumberFormat.getInstance();
           // nf.setMinimumIntegerDigits(4);
           // nf.setGroupingUsed(false);
           // return nf.format(time) + "+" + nf.format(duration) + ":" + getNoteValue();
            return "+" + ":" + getNoteValue();
        }
    }

    protected MusicFile() {
    }

    /** Returns the number of channels in this music file. */
	public abstract int getChannelCount();
	
	/**
	 * Retrieves the {@link Note}s from the file. Only notes in the specified
	 * channel(s) will be retrieved. If channels is empty, all channels will be retrieved.
	 */
	public List<Note> getNotes(Collection<Integer> channels) {
		// Retrieve from cache if we've already extracted the notes.
		if (_notes.get(channels) == null) {
			List<Note> notes = extractNotes(channels);
			sortNotes(notes);
			_notes.put(channels, notes);
		}
		return _notes.get(channels);
	}

	/**
	 * Sorts the notes and removes duplicates since we don't want to assign two fingerings
	 * to the exact same note.
	 */
	private void sortNotes(List<Note> notes) {
		Collections.sort(notes);
		Note prev = null;
		for (Iterator<Note> it = notes.iterator(); it.hasNext();) {
			Note n = it.next();
			if (sameNote(prev, n)) {
				it.remove();
			}
			prev = n;
		}
	}
	
	/**
	 * Checks if two (possibly null) notes are the same -- note, time, duration.
	 */
	private boolean sameNote(Note n1, Note n2) {
		if (n1 == null && n2 != null || n1 != null && n2 == null) {
			return false;
		}
		if (n1 == null && n2 == null) {
			return true;
		}
		return n1.note == n2.note && n1.duration == n2.duration && n1.time == n2.time;
	}

	/**
	 * Stores the parsed file to an output stream.
	 * 
	 * Note: This isn't currently implemented by all subclasses and is, in fact, the
	 * wrong design. Instead of having a MusicFile that reads the file, extracts the
	 * notes, and stores its state back out again, there should be a MusicFile that
	 * reads and extracts a list of Notes, and a MusicFileWriter that accepts a list
	 * of Notes and writes out a file in that format. As currently written, it is
	 * not possible to, for example, read a MIDI file and write a MusNotes file.
	 * The suggestion here would be the way to fix this shortcoming.
	 * One difficulty with that approach is that each File type extracts a subclass
	 * of Note with additional information necessary to write the file back out.
	 */
	public void store(OutputStream out) {
	}
	
	/**
	 * Extracts the {@link Note}s in the music file. Only notes in the specified
	 * channel(s) will be extracted. If channels is empty, all channels will be extracted.
	 */
    protected abstract List<Note> extractNotes(Collection<Integer> channels);

    /**
     * Reads the next byte from a stream. Support method for subclasses.
     */
    protected int read(InputStream in) throws IOException {
        int val = in.read();
        if (val < 0) throw new IOException("Premature end of file.");
        return val;
    }

    /**
     * Reads the next 'length' bytes from a stream into a buffer 'buff'. Support method for subclasses.
     */
    protected void read(InputStream in, byte[] buff, int length) throws IOException {
        int val = in.read(buff, 0, length);
        if (val != length)
            throw new IOException("Premature end of file. Expected: " + length + "; read: " + val);
    }
}
