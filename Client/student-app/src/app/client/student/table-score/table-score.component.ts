import { Component, OnInit } from '@angular/core';
import { AuthService } from '../../../shared/services/auth/auth.service';
import { ScoreService } from './score.service';

@Component({
  selector: 'app-table-score',
  templateUrl: './table-score.component.html',
  styleUrls: ['./table-score.component.css'],
  providers:[ScoreService]
})
export class TableScoreComponent implements OnInit {

  detail: any[]
  result:any[]
  constructor(private scoreService:ScoreService,private auth:AuthService) { }

  ngOnInit(): void {
    this.auth.getUserId().subscribe(id => {
      this.scoreService.GetDetail(id).subscribe(table_score => {
        this.detail = table_score
      })
      this.scoreService.GetResultLearning(id).subscribe(result_learning => {
        this.result = result_learning
        
      })     
    })
  }
}
