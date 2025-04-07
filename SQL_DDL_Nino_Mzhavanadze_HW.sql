This XML file does not appear to have any style information associated with it. The document tree is shown below.
<mxfile host="app.diagrams.net">
<diagram name="ERD" id="05b2010a5b05">
<mxGraphModel>
<root>
<mxCell id="0"/>
<mxCell id="1" parent="0"/>
<mxCell id="2" value="<b>donor</b><br>donor_id (PK)<br>first_name<br>last_name<br>email (UNIQUE)<br>phone (UNIQUE)<br>full_name (GEN)<br>record_ts" style="shape=swimlane;whiteSpace=wrap;html=1;" vertex="1" parent="1">
<mxGeometry x="80" y="80" width="200" height="180" as_="geometry"/>
</mxCell>
<mxCell id="3" value="<b>campaign_event</b><br>event_id (PK)<br>event_name<br>event_date<br>location<br>budget<br>record_ts" style="shape=swimlane;whiteSpace=wrap;html=1;" vertex="1" parent="1">
<mxGeometry x="380" y="80" width="200" height="180" as_="geometry"/>
</mxCell>
<mxCell id="4" value="<b>contribution</b><br>contribution_id (PK)<br>donor_id (FK)<br>event_id (FK)<br>contribution_date<br>amount<br>record_ts" style="shape=swimlane;whiteSpace=wrap;html=1;" vertex="1" parent="1">
<mxGeometry x="680" y="80" width="200" height="180" as_="geometry"/>
</mxCell>
<mxCell id="5" value="<b>volunteer</b><br>volunteer_id (PK)<br>first_name<br>last_name<br>gender<br>email (UNIQUE)<br>phone (UNIQUE)<br>full_name (GEN)<br>record_ts" style="shape=swimlane;whiteSpace=wrap;html=1;" vertex="1" parent="1">
<mxGeometry x="980" y="80" width="200" height="180" as_="geometry"/>
</mxCell>
<mxCell id="6" value="<b>volunteer_role</b><br>role_id (PK)<br>role_name<br>role_description<br>record_ts" style="shape=swimlane;whiteSpace=wrap;html=1;" vertex="1" parent="1">
<mxGeometry x="80" y="380" width="200" height="180" as_="geometry"/>
</mxCell>
<mxCell id="7" value="<b>volunteer_assignment</b><br>volunteer_id (PK, FK)<br>role_id (PK, FK)<br>start_date<br>end_date<br>record_ts" style="shape=swimlane;whiteSpace=wrap;html=1;" vertex="1" parent="1">
<mxGeometry x="380" y="380" width="200" height="180" as_="geometry"/>
</mxCell>
<mxCell id="8" value="<b>volunteer_event</b><br>volunteer_id (PK, FK)<br>event_id (PK, FK)<br>assigned_task<br>hours_assigned<br>record_ts" style="shape=swimlane;whiteSpace=wrap;html=1;" vertex="1" parent="1">
<mxGeometry x="680" y="380" width="200" height="180" as_="geometry"/>
</mxCell>
<mxCell id="9" value="<b>problem</b><br>problem_id (PK)<br>event_id (FK)<br>problem_description<br>date_reported<br>severity<br>record_ts" style="shape=swimlane;whiteSpace=wrap;html=1;" vertex="1" parent="1">
<mxGeometry x="980" y="380" width="200" height="180" as_="geometry"/>
</mxCell>
<mxCell id="10" value="<b>expense</b><br>expense_id (PK)<br>event_id (FK)<br>expense_date<br>expense_amount<br>category<br>payee<br>record_ts" style="shape=swimlane;whiteSpace=wrap;html=1;" vertex="1" parent="1">
<mxGeometry x="80" y="680" width="200" height="180" as_="geometry"/>
</mxCell>
<mxCell id="11" value="<b>survey</b><br>survey_id (PK)<br>event_id (FK)<br>survey_name<br>survey_date<br>target_group<br>record_ts" style="shape=swimlane;whiteSpace=wrap;html=1;" vertex="1" parent="1">
<mxGeometry x="380" y="680" width="200" height="180" as_="geometry"/>
</mxCell>
<mxCell id="12" value="<b>survey_question</b><br>question_id (PK)<br>survey_id (FK)<br>question_text<br>record_ts" style="shape=swimlane;whiteSpace=wrap;html=1;" vertex="1" parent="1">
<mxGeometry x="680" y="680" width="200" height="180" as_="geometry"/>
</mxCell>
<mxCell id="13" value="<b>voter</b><br>voter_id (PK)<br>first_name<br>last_name<br>date_of_birth<br>address<br>full_name (GEN)<br>record_ts" style="shape=swimlane;whiteSpace=wrap;html=1;" vertex="1" parent="1">
<mxGeometry x="980" y="680" width="200" height="180" as_="geometry"/>
</mxCell>
<mxCell id="14" value="<b>survey_response</b><br>response_id (PK)<br>question_id (FK)<br>voter_id (FK)<br>response_value<br>record_ts" style="shape=swimlane;whiteSpace=wrap;html=1;" vertex="1" parent="1">
<mxGeometry x="80" y="980" width="200" height="180" as_="geometry"/>
</mxCell>
</root>
</mxGraphModel>
</diagram>
</mxfile>