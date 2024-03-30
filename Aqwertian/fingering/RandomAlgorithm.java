//  Copyright (c) 2001 Aqwertian, Inc. All rights reserved.
package Aqwertian.fingering;

import java.util.Collection;
import java.util.Map;
import java.util.Random;

import Aqwertian.fingering.MusicFile.Note;

/**
 * An algorithm that simply assigns fingers randomly.
 * 
 * @author Robert Gardner (robert@rdgardnerfamily.com)
 */
public class RandomAlgorithm implements MapAlgorithm {
	private final Random rand = new Random();

	public RandomAlgorithm(QwertyMapper m) {
    }

    public String getInfo() {
        return "Random key assignment.";
    }

    public void map(Collection<Note> notes, PatternList patterns, Map<String, Integer> notesHistogram) {
        for (Note n : notes) {
            int q;
            do {
                q = rand.nextInt(QwertyMapper.FINGER.length);
            } while (QwertyMapper.FINGER[q].length() == 0);
            n.qwerty = (char)(QwertyMapper.FINGER_START + q);
        }
    }
}
