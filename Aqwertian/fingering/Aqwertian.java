//  Copyright (c) 2001 Aqwertian, Inc. All rights reserved.
package Aqwertian.fingering;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.Collection;

import Aqwertian.fingering.MusicFile.Note;
import Aqwertian.fingering.QwertyMapper.Algorithm;
import Aqwertian.fingering.QwertyMapper.LevelOfDifficulty;

/**
 * The main entry point for adding aqwertian fingering to a music file.
 * 
 * @author Robert Gardner (robert@rdgardnerfamily.com)
 */
public class Aqwertian {
	private static final Algorithm ALGO = Algorithm.USAGE;
    
	private static void printStats(QwertyMapper qm, Collection<Note> notes, PatternList patterns) {
		int count = 250;
		System.out.println(patterns.toString());
		System.out.print(notes.size() + " notes: ");
		System.out.println(qm.getInfo());
		for (Note note : notes) {
			//			NumberFormat nf = NumberFormat.getInstance();
			//			nf.setMinimumIntegerDigits(4);
			//			nf.setGroupingUsed(false);
			//			System.out.println(nf.format(note.time) + ' ' + note.note);
			if (--count >= 0)
				System.out.println(qm.toString(note));
			else
				break;
		}
		System.out.println();
		qm.printStatistics(notes);
		System.out.println("----------------");
		System.out.println();
	}

	private static MusicFile createMusicFile(String fileName) throws IOException {
		MusicFile mf;
		FileInputStream file = new FileInputStream(fileName);
		if (fileName.endsWith(".mus"))
			mf = new MusPlayFile(file);
		else if (fileName.endsWith(".nts"))
			mf = new MusNotesFile(file);
		else
			mf = new MidiFile(file);
		file.close();
		return mf;
	}

	private static PatternList getPatterns(String fileName) {
		try {
			FileReader pfile = new FileReader(fileName + ".patterns");
			PatternList patterns = new PatternList(pfile);
			pfile.close();
			return patterns;
		} catch (IOException e) {
			return new PatternList();
		}
	}

	private static void storeMusicFile(MusicFile m, String fileName) throws IOException {
		// Note: MIDI has not (yet) implemented store() so those files must be converted
		// to a different format before being written.
		OutputStream out = new FileOutputStream(fileName);
		m.store(out);
		out.close();
	}
    
	public static void aqw_main(String args[]) {
		try {
			if (args.length == 0) {
				System.out.println("Usage: Aqwertian -level infile outfile");
				System.out.println("    level is optional and must be one of");
				System.out.println("    b(eginner), i(ntermediate), a(dvanced), e(xpert)");
				System.out.println("    default is expert.");
				return;
			}
			LevelOfDifficulty level = LevelOfDifficulty.EXPERT;
			int index = 0;
			String parm = args[index];
			if (parm.startsWith("-")) {
				char l = parm.charAt(1);
				if (l == 'b') level = LevelOfDifficulty.BEGINNER;
				else if (l == 'i') level = LevelOfDifficulty.INTERMEDIATE;
				else if (l == 'a') level = LevelOfDifficulty.ADVANCED;
				else if (l == 'e') level = LevelOfDifficulty.EXPERT;
				index++;
			}
			String infile = args[index];
			index++;
			String outfile = infile + ".out";
			if (args.length >= index + 1)
				outfile = args[index];
			MusicFile midi = createMusicFile(infile);
			PatternList patterns = getPatterns(infile);
			Collection<Note> notes = midi.getNotes(new ArrayList<Integer>());
			QwertyMapper qm = new QwertyMapper(ALGO, level);
			qm.map(notes, patterns);
			printStats(qm, notes, patterns);
			storeMusicFile(midi, outfile);
		} catch (Exception ex) {
			ex.printStackTrace();
		}
	}
}
