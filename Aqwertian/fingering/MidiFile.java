//  Copyright (c) 2001 Aqwertian, Inc. All rights reserved.
package Aqwertian.fingering;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * Reads a MIDI file and extracts {@link Note}s from one or more of the channels.
 * File format documentation: http://www.sonicspot.com/guide/midifiles.html
 * 
 * @author Robert Gardner (robert@rdgardnerfamily.com)
 */
public class MidiFile extends MusicFile {
	private final int _format;
	private final int _numTracks;
    private final int _division;
    private final List<Event> _events;

    /** An abstract MIDI chunk. Subclasses define and parse specific chunk types. */
    private static abstract class Chunk {
        @SuppressWarnings("unused")
		public String id;
        @SuppressWarnings("unused")
        public int length;

        Chunk(String id, int length) {
            this.id = id;
            this.length = length;
        }
    }

    /** A generic chunk, one that we don't have specific information about. */
    private static class GenericChunk extends Chunk {
        GenericChunk(String id, int length) {
            super(id, length);
        }
    }

    /** A MIDI Header chunk. */
    private static class MThdChunk extends Chunk {
        public int format;
        public int numTracks;
        public int division;

        MThdChunk(String id, int length, byte[] data) {
            super(id, length);
            format = (data[0] << 8) + data[1];
            numTracks = (data[2] << 8) + data[3];
            division = (data[4] << 8) + data[5];
        }
    }

    /** A MIDI Track chunk. */
    private static class MTrkChunk extends Chunk {
        MTrkChunk(String id, int length, byte[] data) throws IOException {
            super(id, length);
            events = new ArrayList<Event>();
            try {
                parseChunk(length, data);
            } catch (IndexOutOfBoundsException e) {
                throw new IOException("Premature end of file reading MTrk");
            }
        }

        private void parseChunk(int len, byte[] data) {
            int offset = 0;
            byte lastStatus = 0;
            while (offset < len) {
                LengthInfo info = readVarLength(data, offset);
                offset = info.offset;
                Event e = new Event();
                e.deltaTime = info.length;
                if ((data[offset] & (byte)0x80) != 0)
                    e.status = data[offset++];
                else
                    e.status = lastStatus;
                lastStatus = e.status;
                if (e.status == (byte)0xFF)
                    offset = parseMetaEvent(e, data, offset);
                else {
                    e.data = new byte[dataLength(e.status)];
                    for (int i = 0; i < e.data.length; i++)
                        e.data[i] = data[offset++];
                }
                events.add(e);
            }
        }

        private int dataLength(byte status) {
            switch (status & (byte)0xF0) {
                case (byte)0x80:
                case (byte)0x90:
                case (byte)0xA0:
                case (byte)0xB0:
                case (byte)0xE0:
                    return 2;
                case (byte)0xC0:
                case (byte)0xD0:
                    return 1;
                case (byte)0xF0:
                    if (status == (byte)0xF1 || status == (byte)0xF3)
                        return 1;
                    if (status == (byte)0xF2)
                        return 2;
            }
            return 0;
        }

        private int parseMetaEvent(Event e, byte[] data, int offset) {
            byte type = data[offset++];
            LengthInfo info = readVarLength(data, offset);
            offset = info.offset;
            e.data = new byte[info.length + 1];
            e.data[0] = type;
            for (int i = 1; i < e.data.length; i++)
                e.data[i] = data[offset++];
            return offset;
        }

        public List<Event> events;
    }

    /** A MIDI event. Events will be converted to {@link Note}s. */
    public static class Event implements Comparable<Event> {
        public int deltaTime;
        public int time;
        public byte status;
        public byte[] data;
        boolean visited;

        public boolean isChannelEvent() {
            byte st = (byte)(status & 0xF0);
            return (st == (byte)0x80 || st == (byte)0x90 || st == (byte)0xA0 || st == (byte)0xB0
            		|| st == (byte)0xC0 || st == (byte)0xD0 || st == (byte)0xE0);
        }

        public boolean isNoteEvent() {
            byte st = (byte)(status & 0xF0);
            return (st == (byte)0x80 || st == (byte)0x90);
        }

        public boolean isNoteOn() {
            return ((byte)(status & 0xF0) == (byte)0x90);
        }

        public boolean isNoteOff() {
            return ((byte)(status & 0xF0) == (byte)0x80);
        }

        public int getChannel() {
            return (status & 0x0F);
        }

        public int getNote() {
            return data[0];
        }

        @Override
		public boolean equals(Object obj) {
            if (obj instanceof Event) {
                Event e = (Event)obj;
                if (time != e.time || status != e.status || data.length != e.data.length)
                    return false;
                for (int i = 0; i < data.length; i++)
                    if (data[i] != e.data[i]) return false;
                return true;
            }
            return false;
        }

        public int compareTo(Event e) {
            if (time != e.time)
                return time - e.time;
            if (status != e.status)
                return status - e.status;
            for (int i = 0; i < data.length; i++) {
                if (i >= e.data.length)
                    break;
                if (data[i] != e.data[i])
                    return data[i] - e.data[i];
            }
            return data.length - e.data.length;
        }

        @Override
		public String toString() {
            StringBuffer buff = new StringBuffer(20);
            toString(buff);
            return buff.toString();
        }

        public void toString(StringBuffer buff) {
            buff.append("t: ").append(time);
            buff.append(", s: ");
            if (status == -1) {
                switch (data[0]) {
                    case 0: // Sequence Number
                        buff.append("SQ");
                        break;
                    case 1:
                    case 2:
                    case 3:
                    case 4:
                    case 5:
                    case 6:
                    case 7:
                    case 8:
                    case 9:
                        buff.append(data[0]).append(':').append(new String(data, 1, data.length - 1));
                        break;
                    case (byte)0x2F: // End of Track
                        buff.append("XX");
                        break;
                    default:
                        buff.append(data[0]).append(':');
                        for (int i = 1; i < data.length; i++)
                            buff.append(Integer.toHexString(data[i]));
                            break;
                }
            } else {
                byte stat = (byte)(status & 0xF0);
                switch (stat) {
                    case (byte)0x80: // Note Off
                        buff.append("UP").append(getChannel());
                        break;
                    case (byte)0x90: // Note On
                        buff.append("DN").append(getChannel());
                        break;
                    case (byte)0xA0: // Note Aftertouch
                        buff.append("AT").append(getChannel());
                        break;
                    case (byte)0xB0: // Controller
                        buff.append("CT").append(getChannel());
                        break;
                    case (byte)0xC0: // Program Change
                        buff.append("PC").append(getChannel());
                        break;
                    case (byte)0xD0: // Channel Aftertouch
                        buff.append("PR").append(getChannel());
                        break;
                    case (byte)0xE0: // Pitch bend (wheel)
                        buff.append("WH").append(getChannel());
                        break;
                    default:
                        buff.append(Integer.toHexString(status).substring(6));
                }
                for (int i = 0; i < data.length; i++)
                    buff.append(" ").append(data[i]);
            }
        }
    }

    public MidiFile(InputStream in) throws IOException {
        MThdChunk header = (MThdChunk)readChunk(in);
        _format = header.format;
        _numTracks = header.numTracks;
        _division = header.division;
        _events = new ArrayList<Event>();
        int lastTime = 0;
        for (int i = 0; i < header.numTracks; i++) {
            Chunk c = readChunk(in);
            if (!(c instanceof MTrkChunk)) continue;
            MTrkChunk mc = (MTrkChunk)c;
            int start;
            if (header.format == 1)
                start = 0;
            else
                start = lastTime;
            calcTime(mc.events, start);
            _events.addAll(mc.events);
        }
        Collections.sort(_events);
    }
    
    @Override
    public int getChannelCount() {
    	Set<Integer> channels = new HashSet<Integer>();
    	for (Event e : _events) {
    		if (e.isChannelEvent())
    			channels.add(e.getChannel());
    	}
    	return channels.size();
    }

    @Override
	protected List<Note> extractNotes(Collection<Integer> channels) {
        List<Note> notes = new ArrayList<Note>();
        for (int i = 0; i < _events.size(); i++) {
            Event e = _events.get(i);
            if (!processChannel(channels, e))
            	continue;
            if (e.isNoteOn()) {
            	int channel = e.getChannel();
                int note = e.getNote();
                boolean foundNoteOff = false;
                for (int j = i + 1; j < _events.size(); j++) {
                    Event f = _events.get(j);
                    if (!f.visited && f.isNoteOff() && channel == f.getChannel() && note == f.getNote()) {
                        f.visited = true;
                        foundNoteOff = true;
                        notes.add(new Note(channel, e.time, f.time - e.time, note));
                        break;
                    }
                }
                if (!foundNoteOff)
                	// No note off! Just use a standard duration
                    notes.add(new Note(channel, e.time, getDefaultDuration(), note));
            }
        }
        // Make sure all note offs were used
        for (int i = 0; i < _events.size(); i++) {
            Event e = _events.get(i);
            if (processChannel(channels, e) && e.isNoteOff() && !e.visited)
                System.out.println("!!!!!!!!!!! Note off at " + i + " was not used: " + e);
        }
        return notes;
    }
    
	private int getDefaultDuration() {
		if (_division >= 0)
			return _division;
		return (_division & 0xFF);
	}

	private boolean processChannel(Collection<Integer> channels, Event e) {
    	if (!e.isNoteEvent())
    		return false;
    	if (channels == null || channels.isEmpty())
    		return true;
    	return channels.contains(e.getChannel());
    }

    @Override
	public String toString() {
        StringBuffer buff = new StringBuffer();
        buff.append("fmt " + _format + ", ");
        buff.append(_numTracks + " tracks, ");
        if (_division >= 0)
            buff.append(_division + " ppqn");
        else
            buff.append("fps: " + -(_division >> 8)).append(" subframe: " + (_division & 0xFF));
        for (Event e : _events) {
            buff.append("; ");
            e.toString(buff);
        }
        return buff.toString();
    }

    private void calcTime(List<Event> events, int start) {
        int prev = start;
        for (Event e : events) {
            e.time = prev + e.deltaTime;
            prev = e.time;
        }
    }

    private Chunk readChunk(InputStream in) throws IOException {
        int val = in.read();
        if (val < 0) return null;
        char[] idb = new char[4];
        String id;
        int length;
        byte[] data;
        idb[0] = (char)val;
        idb[1] = (char)read(in);
        idb[2] = (char)read(in);
        idb[3] = (char)read(in);
        id = String.valueOf(idb);
        length = read(in) << 24;
        length += read(in) << 16;
        length += read(in) << 8;
        length += read(in);
        if (length < 0 || length > 10 * 1024 * 1024)
        	throw new IOException("Illegal chunk size: " + length);
        data = new byte[length];
        read(in, data, data.length);
        if ("MThd".equals(id))
            return new MThdChunk(id, length, data);
        if ("MTrk".equals(id))
            return new MTrkChunk(id, length, data);
        return new GenericChunk(id, length);
    }

    private static class LengthInfo {
        public int length;
        public int offset;

        LengthInfo(int length, int offset) {
            this.length = length;
            this.offset = offset;
        }
    }

    private static LengthInfo readVarLength(byte[] data, int offset) {
        int len = data[offset++];
        if ((len & 0x80) != 0) {
            len &= 0x7F;
            int val;
            do {
                val = data[offset++];
                len = (len << 7) + (val & 0x7F);
            } while ((val & 0x80) != 0);
        }
        return new LengthInfo(len, offset);
    }
}
