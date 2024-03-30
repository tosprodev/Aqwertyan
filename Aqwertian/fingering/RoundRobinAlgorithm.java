//  Copyright (c) 2001 Aqwertian, Inc. All rights reserved.
package Aqwertian.fingering;

import java.util.Collection;
import java.util.Map;

import Aqwertian.fingering.MusicFile.Note;

/**
 * An algorithm that assigns fingers round-robin.
 * 
 * @author Robert Gardner (robert@rdgardnerfamily.com)
 */
public class RoundRobinAlgorithm implements MapAlgorithm {
    private final QwertyMapper _mapper;

    public RoundRobinAlgorithm(QwertyMapper m) {
        _mapper = m;
    }

    public String getInfo() {
        return "Round robin finger assignment, round robin row.";
    }

    private static final String[] FINGERS = {
        "L1", "R1", "L2", "R2", "L3", "R3", "L4", "R4", "T0"
    };

    private static final int[] ROWS = {
        1, 2, 3, 4, 3, 2
    };

    public void map(Collection<Note> notes, PatternList patterns, Map<String, Integer> notesHistogram) {
        int finger = 0;
        int row = 0;
        for (Note n : notes) {
            String f = FINGERS[finger];
            if (++finger >= FINGERS.length) finger = 0;
            if (f.equals("T0"))
                n.qwerty = _mapper.getQwerty(f, 0);
            else {
                do {
                    n.qwerty = _mapper.getQwerty(f, ROWS[row]);
                    if (++row >= ROWS.length) row = 0;
                } while (n.qwerty == 0);
            }
        }
    }
}
