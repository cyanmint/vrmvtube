# Model Metadata Display Panel

## Overview
The metadata panel displays comprehensive information about loaded VRM models, including creator details, usage permissions, and license information.

## Features

### What's Displayed

#### Basic Information
- **Title**: Model name/title
- **Version**: Model version number
- **Author**: Creator name(s)
- **Contact**: Creator contact information
- **References**: Related links or references

#### Usage Permissions
- **Allowed Users**: Who can use this model
  - OnlyAuthor
  - ExplicitlyLicensedPerson
  - Everyone
- **Commercial Usage**: Commercial use permissions
  - PersonalNonProfit
  - PersonalProfit
  - AllowCorporation
- **Violent Content**: Use in violent content (Allow/Disallow)
- **Sexual Content**: Use in sexual content (Allow/Disallow)
- **Credit Notation**: Whether credit is required (Required/Unnecessary)
- **Modification**: Modification rights
  - Prohibited
  - AllowModification
  - AllowModificationRedistribution
- **Redistribution**: Redistribution rights (Allow/Disallow)

#### License Information
- **License Name**: Type of license (CC0, CC_BY, CC_BY_NC, etc.)
- **License URL**: Link to license document
- **Other License URL**: Additional license information
- **Third Party Licenses**: Dependencies and their licenses

#### Technical Information
- **VRM Spec Version**: VRM specification version (0.0, 1.0, etc.)
- **Exporter Version**: Tool used to create the VRM (e.g., UniVRM-0.98.0)

## Usage

### Viewing Metadata

1. **Load a VRM model**
   - Use "Load VRM Model" button
   - Or app loads default model on startup

2. **Metadata panel appears**
   - Located below Model Controls panel
   - Automatically populated with model info

3. **Scroll to read**
   - Panel has scrollbar for long metadata
   - All information is formatted for readability

### Collapsing/Expanding

**To Collapse:**
- Click ▼ button in panel header
- Content hides, only header visible

**To Expand:**
- Click ▲ button in panel header
- Content shows again

## Example Metadata Display

```
VRM Metadata

Title: Sample Avatar
Version: 1.0
Author: Creator Name
Contact: creator@example.com

Permissions:
• User: Everyone
• Commercial: AllowCorporation
• Violent Content: Disallow
• Sexual Content: Disallow
• Credit: Required
• Modification: AllowModification
• Redistribution: Allow

License:
• CC_BY
• URL: https://creativecommons.org/licenses/by/4.0/

Technical Info:
• VRM Spec: 0.0
• Exporter: UniVRM-0.98.0
```

## Interpreting Permissions

### Allowed Users

**OnlyAuthor:**
- Only the creator can use this model
- Don't use unless you are the creator

**ExplicitlyLicensedPerson:**
- Only people explicitly given permission
- Need written permission from creator

**Everyone:**
- Anyone can use the model
- Check other permissions for restrictions

### Commercial Usage

**PersonalNonProfit:**
- Personal use only
- No monetization allowed
- Can't use for business

**PersonalProfit:**
- Can monetize as individual
- Personal streams/videos OK
- No corporate/company use

**AllowCorporation:**
- Full commercial use allowed
- Companies can use
- Monetization permitted

### Violent/Sexual Content

**Allow:**
- Can be used in these types of content

**Disallow:**
- Must not be used in these contexts
- Respect creator's wishes

### Credit Notation

**Required:**
- Must credit the creator
- Include credit in streams/videos
- Link to creator if possible

**Unnecessary:**
- Credit not required
- But still nice to give credit

### Modification

**Prohibited:**
- Cannot modify the model
- Use as-is only

**AllowModification:**
- Can modify for personal use
- Can't redistribute modifications

**AllowModificationRedistribution:**
- Can modify
- Can share modified versions

### Redistribution

**Allow:**
- Can share the model with others
- Check license for conditions

**Disallow:**
- Cannot share the model file
- Only you can use your copy

## No Metadata Found

If metadata panel shows "No VRM metadata found":

### Possible Reasons

1. **Not a VRM file**
   - File is generic GLTF/GLB
   - No VRM-specific metadata

2. **Metadata not included**
   - Creator didn't fill in metadata
   - Exported without metadata

3. **Older VRM format**
   - Very old VRM files may lack metadata
   - Pre-standard versions

### What to Do

- Check model source for license info
- Contact model creator
- Don't assume usage is allowed
- When in doubt, don't use commercially

## Best Practices

### Before Using a Model

1. **Read the metadata**
   - Check all permissions
   - Note restrictions
   - Understand license

2. **Check commercial use**
   - If streaming/monetizing
   - If in corporate setting
   - If selling products

3. **Give credit**
   - If required
   - Even if not required (good practice)
   - Link to creator

4. **Respect restrictions**
   - Don't use in prohibited contexts
   - Follow modification rules
   - Honor redistribution terms

### For Streamers/VTubers

**Before Going Live:**
- Verify commercial usage allowed
- Check credit requirements
- Note any content restrictions
- Prepare credit information

**During Stream:**
- Give credit as required
- Follow content guidelines
- Don't modify if prohibited

**Sharing/Collaboration:**
- Check redistribution rights
- Don't share if prohibited
- Share license info with collaborators

### For Developers

**Before Integration:**
- Check modification rights
- Verify commercial terms
- Note technical requirements
- Review redistribution rules

**In Projects:**
- Include required credits
- Respect modification limits
- Follow license terms
- Document model sources

## Legal Considerations

### Licenses

**CC0 (Public Domain):**
- Free to use however
- No attribution required
- No restrictions

**CC BY (Attribution):**
- Free to use
- Must credit creator
- Can modify and redistribute

**CC BY-NC (Attribution-NonCommercial):**
- Personal use only
- Must credit creator
- No commercial use

**CC BY-SA (Attribution-ShareAlike):**
- Must credit creator
- Derivatives under same license
- Can use commercially

**CC BY-ND (Attribution-NoDerivatives):**
- Must credit creator
- Cannot modify
- Can use commercially

**Other/Custom:**
- Read full license
- Contact creator if unclear
- May have specific terms

### When in Doubt

- **Contact the creator** - Ask for clarification
- **Don't assume** - Lack of info ≠ permission
- **Be conservative** - When unclear, don't use commercially
- **Get written permission** - For important projects
- **Consult lawyer** - For commercial/corporate use

## Troubleshooting

### Metadata Not Showing

**Check:**
1. Model is loaded (not just scene)
2. Metadata panel is expanded (▼/▲)
3. Scroll down in metadata panel
4. Try reloading the model

**If Still Not Showing:**
- Model may not have metadata
- See "No Metadata Found" section

### Incorrect Metadata

**Possible Issues:**
1. Creator entered wrong information
2. Metadata from older export
3. Model was modified

**Solutions:**
- Verify with creator
- Check model source
- Use original version

### Can't Read Metadata

**If Text Too Small:**
- Not currently resizable
- Try larger window
- Check monitor scaling

**If Text Cut Off:**
- Scroll within panel
- Panel has scrollbar
- All content is there

## Future Features

Planned enhancements:

1. **Thumbnail Display**
   - Show model preview image
   - From VRM thumbnail metadata

2. **Export Metadata**
   - Save to text file
   - Print-friendly format
   - Include in credits easily

3. **Metadata Editor**
   - Edit metadata
   - Re-export with changes
   - For model creators

4. **Quick Credit Copy**
   - Copy credit text
   - Ready to paste
   - Formatted for descriptions

5. **License Detector**
   - Highlight restrictions
   - Warn about violations
   - Suggest proper usage

## Technical Details

### Metadata Source

VRM metadata is stored in the `.vrm` file as part of the VRM extension to GLTF. It's extracted from:

```
VRM Node
├─ vrm_meta (Resource)
│  ├─ title
│  ├─ version
│  ├─ authors
│  ├─ contact_information
│  ├─ allowed_user_name
│  ├─ commercial_usage_type
│  └─ ... (other fields)
```

### Extraction Process

1. Load VRM file
2. Search node tree for `vrm_meta`
3. Extract metadata fields
4. Format for display
5. Show in panel

### Display Format

- Rich text with BBCode formatting
- Bold headers for sections
- Bullet points for lists
- Scrollable container
- Responsive layout

## Summary

The metadata panel provides essential information about VRM models, helping users:
- Understand usage rights
- Respect creator permissions
- Follow license terms
- Give proper attribution
- Use models legally and ethically

**Always read and respect model metadata!**
