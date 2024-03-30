//  Copyright (c) 2001 Aqwertian, Inc. All rights reserved.
package Aqwertian.fingering;

import java.util.Collection;
import java.util.Map;

import Aqwertian.fingering.MusicFile.Note;

/**
 * Defines an algorithm type for finger mapping. Implementations can provide different
 * algorithmic techniques for the fingering.
 * 
 * @author Robert Gardner (robert@rdgardnerfamily.com)
 */
public interface MapAlgorithm {
    String getInfo();
    void map(Collection<Note> notes, PatternList patterns, Map<String, Integer> notesHistogram);
}
