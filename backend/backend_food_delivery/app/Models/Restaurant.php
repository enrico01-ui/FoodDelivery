<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Restaurant extends Model
{
    use HasFactory;

    protected $table = "restaurants";

    protected $fillable = [
        'id',
        'name',
        'address',
        'description',
        'phone_number',
        'rating',
        'logo_url',
        'open_time',
        'close_time'
    ];

}
